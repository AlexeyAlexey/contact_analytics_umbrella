defmodule ContactAnalytics.CustomAttrs.DocFilter do
  alias ContactAnalytics.CustomAttrs.CustomAttr

  def filter_attrs(%{app_id: app_id} = doc) do
    attr_ids = Map.take(doc, CustomAttr.attr_names)
    |> Map.values()
    |> List.flatten()
    |> Enum.reduce([], fn el, acc -> [el[:id] | acc] end)

    res = Mongo.aggregate(:mongo, CustomAttr.collection_name,
       [%{"$match" => %{app_id: app_id, data_type: %{ "$in" => CustomAttr.data_types }, id: %{"$in" => attr_ids }}},
        %{"$group" => %{ _id: "$data_type", ids: %{"$push" => "$id"}}},
        %{"$project" => %{_id: 0, data_type: "$_id", ids: "$ids" }}])

    case res do
      %Mongo.Stream{docs: data_type_ids} ->
        filter_attr_values(doc, data_type_ids)

      {:error, error} ->
        {:error, error}
    end
  end

  defp filter_attr_values(doc, data_type_ids) do

    ids = Enum.reduce(data_type_ids, %{}, fn el, acc -> Map.put(acc, :"attr_#{el["data_type"]}", el["ids"]) end)

    Enum.reduce(CustomAttr.attr_names, doc, fn attr_name, acc ->

       if Map.has_key?(acc, attr_name) && Map.has_key?(ids, attr_name) do
         attr_ids = Map.get(ids, attr_name)

         filtered = Enum.reject(acc[attr_name], fn attr_el -> attr_el[:id] not in attr_ids end)

         Map.put(acc, attr_name, filtered)
       else
         Map.delete(acc, attr_name)
       end
    end)
  end
end
