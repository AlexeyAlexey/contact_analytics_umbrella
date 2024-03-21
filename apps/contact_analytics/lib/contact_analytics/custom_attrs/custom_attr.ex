defmodule ContactAnalytics.CustomAttrs.CustomAttr do
  @moduledoc false
  use Mongo.Collection
  use Ecto.Schema

  import Ecto.Changeset

  alias EctoExt.DataType.{BSONObjectId, InList}

  @data_types ["bigint", "decimal", "float", "string", "utc_datetime"]

  @attr_names [:attr_string,
               :attr_bigint,
               :attr_float,
               :attr_decimal,
               :attr_utc_datetime]

  # collection :custom_attrs do
  #   attribute :app_id, BSON.ObjectId.t()
  #   attribute :id, Integer.t()
  #   attribute :name, String.t()
  #   attribute :data_type, String.t()

  #   timestamps()
  # end

  def collection_name, do: "custom_attrs"

  def data_types, do: @data_types
  def attr_names, do: @attr_names

  @primary_key false
  schema "custom_attrs" do
    field :_id, BSONObjectId
    field :app_id, BSONObjectId
    field :id, :integer
    field :name, :string
    field :data_type, InList, in: @data_types
    field :deleted, :boolean

    timestamps()
  end

  # https://hexdocs.pm/ecto/Ecto.Changeset.html#module-schemaless-changesets
  # @coll_schema_ecto %{app_id: EctoBSONObjectId,
  #                     id: :integer,
  #                     name: :string,
  #                     data_type: Ecto.ParameterizedType.init(EctoInList, in: ["bigint", "decimal", "real", "string"]),
  #                     inserted_at: :utc_datetime_usec,
  #                     updated_at: :utc_datetime_usec}

  # def coll_schema_ecto, do: @coll_schema_ecto



  def changeset_insert(custom_attr, params) do
    custom_attr
    |> cast(params, [:app_id, :name, :id, :data_type, :deleted, :inserted_at, :updated_at])
    |> validate_required([:app_id, :id, :name, :data_type, :deleted, :inserted_at, :updated_at])
  end

  def changeset_update(custom_attr, params) do
    custom_attr
    |> cast(Map.put_new(params, :updated_at, DateTime.utc_now()), [:app_id, :_id, :name, :deleted, :updated_at])
    |> validate_required([:app_id, :_id, :updated_at])
  end
end
