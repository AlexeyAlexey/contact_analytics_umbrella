defmodule ContactAnalytics.CustomAttrsFixtures do
  alias ContactAnalytics.CustomAttrs.CustomAttr

  @moduledoc """
  This module defines test helpers for creating
  entities via the `ContactAnalytics.CustomAttrs` context.
  """

  @doc """
  Generate a custom_attr.
  """
  def custom_attr_fixture(%{app_id: app_id} = attrs) do
    # {:ok, app_id} = BSON.ObjectId.decode(app_id)

    Mongo.insert_many(:mongo,
                      CustomAttr.collection_name, [
                        %{app_id: app_id, id: 1, name: "name1", data_type: "bigint", inserted_at: DateTime.utc_now()},
                        %{app_id: app_id, id: 2, name: "name2", data_type: "bigint", inserted_at: DateTime.utc_now()}
                      ])
  end
end
