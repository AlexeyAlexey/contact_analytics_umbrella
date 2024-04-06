defmodule ContactAnalytics.Contacts do
  @moduledoc """
  The Contacts context.
  """

  # import Ecto.Query, warn: false
  # alias ContactAnalytics.Repo

  alias ContactAnalytics.Contacts.Contact

  alias ContactAnalytics.CustomAttrs.{ChangesetConv}
  alias ContactAnalytics.CustomAttrs


  def create_contacts([], _app_id) do
    []
  end

  def create_contacts(docs, app_id) do
    time_now = DateTime.utc_now()

    Enum.reduce(docs, [[], []], fn doc, acc ->
      Map.merge(doc, %{"app_id" => app_id,
                       "inserted_at" => time_now,
                       "updated_at" => time_now})
      |> Contact.changeset_insert()
      |> case do

        %Ecto.Changeset{valid?: true, changes: changes} ->
          valid_doc = ChangesetConv.to_map(changes)

          [valid_docs, _] = acc

          List.replace_at(acc, 0, [valid_doc | valid_docs])

        %Ecto.Changeset{valid?: false, changes: changes, errors: errors} ->

          [_, not_valid_docs] = acc

          List.replace_at(acc, 1, [%Ecto.Changeset{valid?: false, changes: changes, errors: errors} | not_valid_docs])
        end
    end)
    |> case do # it should be refactored
      [[], invalid_docs] ->
        [[], invalid_docs]
      [valid_docs, invalid_docs] ->
        case insert_many(valid_docs) do
          {:ok, ids} ->
            [ids, [], invalid_docs]

          {:error, errors} ->
            [[], errors, invalid_docs]
        end
    end
  end

  def create_contact(nil, app_id) do
    {:error, "doc cannot be nil"}
  end

  def create_contact(doc, app_id) do
    time_now = DateTime.utc_now()

    Map.merge(doc, %{"app_id" => app_id,
                     "inserted_at" => time_now,
                     "updated_at" => time_now})
    |> Contact.changeset_insert()
    |> case do
      %Ecto.Changeset{valid?: true, changes: changes} ->
        ChangesetConv.to_map(changes)
        |> insert_one

      %Ecto.Changeset{valid?: false, changes: _, errors: errors} ->
        {:error, errors}
    end
  end

  defp insert_one(doc) do
    case Mongo.insert_one(:mongo, Contact.collection_name, doc) do

      {:ok, %Mongo.InsertOneResult{inserted_id: inserted_id}} ->
        {:ok, Map.put(doc, :_id, inserted_id)}

      {:error, errors} ->
        {:error, errors}
    end
  end

  defp insert_many(docs) do
    case Mongo.insert_many(:mongo, Contact.collection_name, docs) do
      {:ok, %Mongo.InsertManyResult{acknowledged: true, inserted_ids: ids}} ->
        {:ok, ids}
      {:error, res} ->
        {:error, res}
    end
  end
end
