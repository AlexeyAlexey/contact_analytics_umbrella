defmodule Mongo.Migrations.Mongo.AddCustomAttrsAppIdIndex do
  def up() do
    indexes = [[key: [app_id: 1], name: "app_id_index"]]

    Mongo.create_indexes(:mongo, "custom_attrs", indexes)
  end

  def down() do
    Mongo.drop_collection(:mongo, "custom_attrs")
  end
end
