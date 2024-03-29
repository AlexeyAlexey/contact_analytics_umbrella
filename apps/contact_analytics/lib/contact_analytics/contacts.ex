defmodule ContactAnalytics.Contacts do
  @moduledoc """
  The Contacts context.
  """

  # import Ecto.Query, warn: false
  # alias ContactAnalytics.Repo

  alias ContactAnalytics.Contacts.Contact

  alias ContactAnalytics.CustomAttrs.{ChangesetConv} # DocFilter
  alias ContactAnalytics.CustomAttrs

  # def create_contacts(attrs, valid_docs \\ [], not_valid_docs \\ [])

  # def create_contacts([], valid_docs, not_valid_docs) do
  #   case Mongo.insert_many(:mongo, Contact.collection_name, valid_docs) do
  #     {:ok, res} ->
  #       {:ok, [res, not_valid_docs]}
  #     {:error, res} ->
  #       {:error, [res, not_valid_docs]}
  #   end
  # end

  def create_contacts(app_id, docs) do
    [validated_docs,
     not_validated_docs,
     failed_params_format] = CustomAttrs.Docs.convert_validate(app_id, docs)

    time_now = DateTime.utc_now()

    docs = Enum.reduce(validated_docs, [[], []], fn doc, acc ->
      doc = Map.merge(doc, %{"inserted_at" => time_now, "updated_at" => time_now})

      case Contact.changeset_insert(%Contact{}, doc) do
        %Ecto.Changeset{valid?: true, changes: changes} ->
          valid_doc = ChangesetConv.to_map(changes)

          [valid_docs, _] = acc

          List.replace_at(acc, 0, [valid_doc | valid_docs])

        %Ecto.Changeset{valid?: false, changes: changes, errors: errors} ->

          [_, not_valid_docs] = acc

          List.replace_at(acc, 1, [%Ecto.Changeset{valid?: false, changes: changes, errors: errors} | not_valid_docs])
        end
    end)

    [validated_docs, not_valid_docs] = docs

    inserted = if validated_docs != [] do
      insert_many(validated_docs)
    end

    [inserted, not_valid_docs]
  end

  def create_contact(%{"app_id" => app_id} = doc) do
    case CustomAttrs.Docs.convert_validate_doc(app_id, doc) do
      [validated_doc, nil, nil] ->

        time_now = DateTime.utc_now()
        doc = Map.merge(doc, %{"inserted_at" => time_now,
                               "updated_at" => time_now})

        case Contact.changeset_insert(%Contact{}, doc) do
          %Ecto.Changeset{valid?: true, changes: changes} ->
            ChangesetConv.to_map(changes)
            |> insert_one

          %Ecto.Changeset{valid?: false, changes: _, errors: errors} ->
            {:error, errors}
        end

      [nil, not_validated_doc, nil] ->

        {:error, not_validated_doc}
      [nil, nil, failed_params_format] ->

        {:error, failed_params_format}
    end
  end

  # def create_contact(%{"app_id" => _app_id} = doc) do
  #    time_now = DateTime.utc_now()
  #    doc = Map.merge(doc, %{"inserted_at" => time_now,
  #                           "updated_at" => time_now})

  #    case Contact.changeset_insert(%Contact{}, doc) do
  #      %Ecto.Changeset{valid?: true, changes: changes} ->
  #        ChangesetConv.to_map(changes)
  #        |> insert_one

  #      %Ecto.Changeset{valid?: false, changes: _, errors: errors} ->
  #        {:error, errors}
  #    end
  # end

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
