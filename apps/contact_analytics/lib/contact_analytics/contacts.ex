defmodule ContactAnalytics.Contacts do
  @moduledoc """
  The Contacts context.
  """

  # import Ecto.Query, warn: false
  # alias ContactAnalytics.Repo

  alias ContactAnalytics.Contacts.Contact

  alias ContactAnalytics.CustomAttrs.{ChangesetConv, DocFilter}
  alias ContactAnalytics.CustomAttrs

  def create_contacts(attrs, valid_docs \\ [], not_valid_docs \\ [])

  def create_contacts([doc | rest] = docs, valid_docs, not_valid_docs) do
    
  end

  def create_contacts([], valid_docs, not_valid_docs) do
    case Mongo.insert_many(:mongo, Contact.collection_name, valid_docs) do
      {:ok, res} ->
        {:ok, [res, not_valid_docs]}
      {:error, res} ->
        {:error, [res, not_valid_docs]}
    end
  end


  def create_contact(%{"app_id" => app_id} = doc) do
     case CustomAttrs.Docs.convert_validate_doc(app_id, doc) do
       [nil, nil, failed_params_format] ->

         {:error, failed_params_format}
       [nil, not_validated_docs, nil] ->

         {:error, not_validated_docs}
       [conv_validated_docs, nil, nil] ->

         time_now = DateTime.utc_now()
         conv_validated_docs = Map.merge(conv_validated_docs, %{"inserted_at" => time_now,
                                                                "updated_at" => time_now})

         case Contact.changeset_insert(%Contact{}, conv_validated_docs) do
           %Ecto.Changeset{valid?: true, changes: changes} ->
             ChangesetConv.to_map(changes)
             |> insert_one
             # |> DocFilter.filter_attrs
             

           %Ecto.Changeset{valid?: false, changes: _, errors: errors} ->
             {:error, errors}
         end
     end

    # time_now = DateTime.utc_now()
    # attrs =Map.merge(attrs, %{inserted_at: time_now,
    #                           updated_at: time_now})

    # case Contact.changeset_insert(%Contact{}, attrs) do
    #   %Ecto.Changeset{valid?: true, changes: changes} ->
    #     ChangesetConv.to_map(changes)
    #     |> DocFilter.filter_attrs
    #     |> insert_one

    #   %Ecto.Changeset{valid?: false, changes: changes} = changeset ->
    #     {:error, changeset}
    # end
  end

  defp insert_one(doc) do
    case Mongo.insert_one(:mongo, Contact.collection_name, doc) do

      {:ok, %Mongo.InsertOneResult{inserted_id: inserted_id}} ->
        {:ok, Map.put(doc, :_id, inserted_id)}

      {:error, errors} ->
        {:error, errors}
    end
  end
end
