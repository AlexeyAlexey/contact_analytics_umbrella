defmodule ContactAnalytics.CustomAttrs.Docs do

  alias ContactAnalytics.CustomAttrs.{AttrSchemas, CustomAttr}

  def convert_validate_doc(doc, app_id) do
    case convert_validate([doc], app_id) do
      [[], [], [failed_params_format | _]] ->

        [nil, nil, failed_params_format]
      [[], [not_validated_docs | _], []] ->

        [nil, not_validated_docs, nil]
      [[conv_validated_docs | _], [], []] ->

        [conv_validated_docs, nil, nil]
    end
  end

  def convert_validate(docs, app_id) do
    %{"present" => present_attrs,
      "not_present" => not_present} = Enum.reduce(docs, %{"present" => [], "not_present" => []}, fn el, acc ->
      if Map.has_key?(el, "attrs") do
        Map.put(acc, "present", [el | Map.get(acc, "present")])
      else
        Map.put(acc, "not_present", [el | Map.get(acc, "not_present")])
      end
    end)

    %{"valid" => valid_params_format, "not_valid" => failed_params_format} = convert_attrs_keys_to_int(present_attrs)

    attr_ids = select_attr_ids(valid_params_format)

    {:ok, ids_data_type} = select_ids_data_type(app_id, attr_ids)
    {:ok, data_type_setts} = select_data_type_setts(app_id, Map.keys(ids_data_type))

    [validated_docs, not_validated_docs] = convert_attrs_to_docs(valid_params_format, ids_data_type, data_type_setts)

    [not_present ++ validated_docs, not_validated_docs, failed_params_format]
  end

  defp select_attr_ids(docs, acc \\ [])

  defp select_attr_ids([%{"attrs" => attrs}| rest], acc) do
    select_attr_ids(rest, Map.keys(attrs) ++ acc)
  end
  defp select_attr_ids([], acc) do
    acc
  end

  defp convert_attrs_to_docs(docs, ids_data_type, data_type_setts, parsed_docs \\ %{"valid_docs" => [],
                                                                                    "not_valid_docs" => []})
  defp convert_attrs_to_docs([%{"attrs" => attrs} = doc | rest_docs], ids_data_type, data_type_setts, parsed_docs) do
    res = case convert_attrs_to_data_type_attrs(attrs, ids_data_type, data_type_setts) do
      {:ok, valid_docs, _} ->
        res = Map.delete(doc, "attrs")
        |> Map.merge(valid_docs)

        Map.put(parsed_docs, "valid_docs", [res | parsed_docs["valid_docs"]])
      {:error, _, not_valid_docs} ->
        res = Map.get(doc, "attrs")
        |> Map.merge(not_valid_docs)

        Map.put(parsed_docs, "not_valid_docs", [Map.put(doc, "attrs", res) | parsed_docs["not_valid_docs"]])
    end

    convert_attrs_to_docs(rest_docs,
                          ids_data_type,
                          data_type_setts,
                          res)
  end
  defp convert_attrs_to_docs([], _, _, parsed_docs) do
    [parsed_docs["valid_docs"], parsed_docs["not_valid_docs"]]
  end

  defp convert_attrs_to_data_type_attrs(attrs, ids_data_type, data_type_setts) when is_map(attrs) do
    Enum.reduce(attrs, [%{}, %{}], fn el, acc ->
      {id, v} = el
      data_type = Map.get(ids_data_type, id)
      setts = Map.get(data_type_setts, id, %{})

      case AttrSchemas.validate(%{id: id, v: v}, data_type, setts) do
        {:ok, doc} ->
          valid_docs = List.last(acc)

          List.replace_at(acc, 1, Map.put(valid_docs, "attr_#{data_type}", [doc | Map.get(valid_docs, "attr_#{data_type}", [])]))

        {:error, errors} ->
          [not_valid | _valid] = acc

          List.replace_at(acc, 0, Map.put(not_valid, id, {v, [errors: errors]}))
      end
    end)
    |> case do
      [not_valid_docs, valid_docs] when map_size(not_valid_docs) == 0 ->
        {:ok, valid_docs, %{}}

      [not_valid_docs, valid_docs] ->
        {:error, valid_docs, not_valid_docs}

    end
  end
  defp convert_attrs_to_data_type_attrs(%{}, _, _) do
    {:ok, %{}, %{}}
  end

  # defp convert_attrs_to_data_type_attrs(attrs, ids_data_type, data_type_setts) when is_map(attrs) do
  #   Enum.reduce(attrs, %{"failed_attrs" => %{}, "failed" => false}, fn el, acc ->
  #     {id, v} = el
  #     data_type = Map.get(ids_data_type, id)

  #     case AttrSchemas.validate(%{id: id, v: v},
  #                               data_type,
  #                               Map.get(data_type_setts, id, %{})) do

  #       {:ok, res} ->
  #         Map.put(acc, "attr_#{data_type}", [res | Map.get(acc, "attr_#{data_type}", [])])

  #       {:error, errors} ->
  #         Map.put(acc, "failed", true)
  #         |>Map.put("attr_#{data_type}", [%{id: id, v: v, errors: errors} | Map.get(acc, "attr_#{data_type}", [])])

  #         # |>Map.put(acc, "failed_attrs", Map.put(Map.get(acc, "failed_attrs"), id, {v, errors: errors}))
  #     end
  #   end)
  #   |> case do
  #     %{"failed" => false} = attr_docs ->
  #       {:ok, Map.delete(attr_docs, "failed")}

  #     attr_docs ->
  #       {:error, Map.delete(attr_docs, "failed")}
  #   end
  # end
  # defp convert_attrs_to_data_type_attrs(%{}, _, _) do
  #   {:ok, %{}}
  # end

  defp convert_attrs_keys_to_int(docs, acc \\ %{"valid" => [], "not_valid" => []})

  defp convert_attrs_keys_to_int([%{"attrs" => attrs} = doc | docs], acc) do
    res = Enum.reduce(attrs, %{"failed" => false}, fn x, acc ->
      {k, v} = x
      case convert_to_integer(k) do
        {k_i, _} ->
          Map.put(acc, k_i, v)
        :error ->
          [errors: [id: {"is invalid", [type: :integer, validation: :cast]}]]
          Map.put(acc, k, {v, [errors: [id: {"is invalid", [type: :integer, validation: :cast]}]]})
          |> Map.put("failed", true)
      end
    end)
    |> case do
      %{"failed" => false} = res->
        res = Map.delete(doc, "attrs")
        |> Map.put("attrs", Map.delete(res, "failed"))

        Map.put(acc, "valid", [res | Map.get(acc, "valid")])

      res ->
        res = Map.delete(doc, "attrs")
        |> Map.put("attrs", Map.delete(res, "failed"))

        Map.put(acc, "not_valid", [res | Map.get(acc, "not_valid")])
    end

    convert_attrs_keys_to_int(docs, res)
  end

  defp convert_attrs_keys_to_int([], acc) do
    acc
  end


  defp select_data_type_setts(_app_id, _ids) do
    # %{ 1234 => %{length: 100}}
    {:ok, %{}}
  end

  # {:ok, ${ id => "bigint" ...}}
  # {:error, error}
  defp select_ids_data_type(app_id, attr_ids) do
    case Mongo.aggregate(:mongo,
                         CustomAttr.collection_name,
                         [%{"$match" => %{"data_type" => %{ "$in" => CustomAttr.data_types},
                                          "app_id" => app_id,
                                          "id" => %{"$in" => attr_ids}}},
                          %{"$group" => %{"_id" => "$data_type", "ids" => %{"$push" => "$id"}}},
                          %{"$project" => %{"_id" => 0, "data_type" => "$_id", "id" => "$ids"}},
                          %{"$unwind" => "$id"}]) do

      %Mongo.Stream{docs: data_type_ids} ->
        res = data_type_ids |> Enum.reduce(%{}, fn el, acc -> Map.put(acc, el["id"], el["data_type"]) end)

        {:ok, res}

      {:error, error} ->
        {:error, error}
    end
  end

  defp convert_to_integer(value) when is_binary(value) do
    Integer.parse(value)
  end
  defp convert_to_integer(value) when is_integer(value) do
    {value, ""}
  end
  defp convert_to_integer(_value) do
    :error
  end
end
