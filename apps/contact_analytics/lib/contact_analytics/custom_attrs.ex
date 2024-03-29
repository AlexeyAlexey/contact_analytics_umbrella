defmodule ContactAnalytics.CustomAttrs do
  alias ContactAnalytics.CustomAttrs.CustomAttr
  # @moduledoc """
  # The CustomAttrs context.
  # """

  # import Ecto.Query, warn: false
  # alias ContactAnalytics.Repo

  # alias ContactAnalytics.CustomAttrs.CustomAttr

  # @doc """
  # Returns the list of custom_attrs.

  # ## Examples

  #     iex> list_custom_attrs()
  #     [%CustomAttr{}, ...]

  # """
  # def list_custom_attrs do
  #   raise "TODO"
  # end

  # @doc """
  # Gets a single custom_attr.

  # Raises if the Custom attr does not exist.

  # ## Examples

  #     iex> get_custom_attr!(123)
  #     %CustomAttr{}

  # """
  # def get_custom_attr!(id), do: raise "TODO"


  def list(%{app_id: app_id} = attrs) do
    app_id = convert_to_object_id(app_id)

    limit = Map.get(attrs, :limit, 100)
    skip = Map.get(attrs, :skip, 0)

    %Mongo.Stream{docs: docs} = Mongo.find(:mongo,
                                           CustomAttr.collection_name,
                                           %{app_id: app_id},
                                           sort: [inserted_at: 1], limit: limit, skip: skip)

    docs
  end

  @doc """
  Creates a custom_attr.

  ## Examples

      iex> create_custom_attr(%{field: value})
      {:ok, %CustomAttr{}}

      iex> create_custom_attr(%{field: bad_value})
      {:error, ...}

  """
  def create_custom_attr(%{app_id: app_id} = attrs) do
    time_now = DateTime.utc_now()
    attrs =
      Map.merge(attrs, %{id: genarate_id(app_id),
                         inserted_at: time_now,
                         updated_at: time_now})
      |> Map.put_new(:deleted, false)

    CustomAttr.changeset_insert(%CustomAttr{}, attrs)
    |> insert_one
  end

  def update_by_id(id, app_id, attrs \\ %{}) do
    attrs = Map.merge(attrs, %{_id: id, app_id: app_id})

    CustomAttr.changeset_update(%CustomAttr{}, attrs)
    |> find_one_and_update
  end

  defp insert_one(%Ecto.Changeset{valid?: true, changes: changes}) do
    case Mongo.insert_one(:mongo, CustomAttr.collection_name, changes) do

      {:ok, %Mongo.InsertOneResult{inserted_id: inserted_id}} ->
        {:ok, Map.put(changes, :_id, inserted_id)}

      {:error, errors} ->
        {:error, errors}
    end
  end

  defp insert_one(%Ecto.Changeset{valid?: false, errors: errors}) do
    {:error, errors}
  end

  defp find_one_and_update(%Ecto.Changeset{valid?: true, changes: changes}) do
    {find, set} = Map.split(changes, [:app_id, :_id])

    case Mongo.find_one_and_update(:mongo,
                              CustomAttr.collection_name,
                              find,
                              %{"$set" => set},
                              [return_document: :after, projection: %{"_id" => 1}]) do

       {:ok, %Mongo.FindAndModifyResult{value: value}} ->
         {:ok, value}

       {:error, errors} ->
         {:error, errors}
    end
  end

  defp find_one_and_update(%Ecto.Changeset{valid?: false, errors: errors}) do
    {:error, errors}
  end

  defp genarate_id(app_id) when is_binary(app_id) do
    {:ok, app_id} = BSON.ObjectId.decode(app_id)

    genarate_id(app_id)
  end

  defp genarate_id(app_id) do
    {:ok, %Mongo.FindAndModifyResult{value: %{"seq" => id}}} =
      Mongo.find_one_and_update(:mongo,
                                "dynamic_attrs_sequence_gen",
                                %{app_id: app_id},
                                %{"$inc" => %{"seq" => 1}},
                                [return_document: :after, upsert: true])

    id
  end

  defp convert_to_object_id(obj_id) when is_binary(obj_id) do
    {:ok, obj_id} = BSON.ObjectId.decode(obj_id)
    obj_id
  end
  defp convert_to_object_id(obj_id) do
    obj_id
  end

  # @doc """
  # Updates a custom_attr.

  # ## Examples

  #     iex> update_custom_attr(custom_attr, %{field: new_value})
  #     {:ok, %CustomAttr{}}

  #     iex> update_custom_attr(custom_attr, %{field: bad_value})
  #     {:error, ...}

  # """
  # def update_custom_attr(%CustomAttr{} = custom_attr, attrs) do
  #   raise "TODO"
  # end

  # @doc """
  # Deletes a CustomAttr.

  # ## Examples

  #     iex> delete_custom_attr(custom_attr)
  #     {:ok, %CustomAttr{}}

  #     iex> delete_custom_attr(custom_attr)
  #     {:error, ...}

  # """
  # def delete_custom_attr(%CustomAttr{} = custom_attr) do
  #   raise "TODO"
  # end

  # @doc """
  # Returns a data structure for tracking custom_attr changes.

  # ## Examples

  #     iex> change_custom_attr(custom_attr)
  #     %Todo{...}

  # """
  # def change_custom_attr(%CustomAttr{} = custom_attr, _attrs \\ %{}) do
  #   raise "TODO"
  # end
end
