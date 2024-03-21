defmodule ContactAnalytics.Contacts.Contact do
  @moduledoc false
  use Mongo.Collection

  use Ecto.Schema
  import Ecto.Changeset

  alias EctoExt.DataType.{BSONObjectId, InList}
  alias ContactAnalytics.CustomAttrs.AttrSchemas.{AttrBigint,
                                                  AttrFloat,
                                                  AttrDecimal,
                                                  AttrString,
                                                  AttrUtcDateTime}


  def collection_name, do: "contacts"

  @primary_key false
  schema "contacts" do
    field :_id, BSONObjectId
    field :app_id, BSONObjectId
    embeds_many :attr_bigint, AttrBigint
    embeds_many :attr_float, AttrFloat
    embeds_many :attr_decimal, AttrDecimal
    embeds_many :attr_string, AttrString
    embeds_many :attr_utc_datetime, AttrUtcDateTime

    timestamps()
  end

  def changeset_insert(custom_attr, params) do
    custom_attr
    |> cast(params, [:app_id, :inserted_at, :updated_at])
    |> cast_embed(:attr_bigint, with: &attr_changeset/2)
    |> cast_embed(:attr_float, with: &attr_changeset/2)
    |> cast_embed(:attr_decimal, with: &attr_changeset/2)
    |> cast_embed(:attr_string, with: &attr_changeset/2)
    |> cast_embed(:attr_utc_datetime, with: &attr_changeset/2)
    |> validate_required([:app_id, :inserted_at, :updated_at])
  end

  defp attr_changeset(schema, params) do
    # params = struct(schema, params) |> Map.from_struct()
    # params = Map.merge(params, %{up_at: nil}, fn _k, v1, _v2 -> v1 end)

    schema
    |> cast(params, [:id, :v, :up_at])
    |> validate_required([:id, :v, :up_at])
  end
end
