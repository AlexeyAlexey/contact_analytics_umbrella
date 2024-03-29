defmodule ContactAnalytics.Repo.Migrations.AddAttrsIndexesContacts do
  def up() do
    indexes = [
      [key: ["attr_bigint.id": 1, "attr_bigint.v": 1], name: "attr_bigint.id_1_attr_bigint.v_1"],
      [key: ["attr_string.id": 1, "attr_string.v": 1], name: "attr_string.id_1_attr_string.v_1"],
      [key: ["attr_float.id": 1, "attr_float.v": 1], name: "attr_float.id_1_attr_float.v_1"],
      [key: ["attr_decimal.id": 1, "attr_decimal.v": 1], name: "attr_decimal.id_1_attr_decimal.v_1"],
      [key: ["attr_utc_date_time.id": 1, "attr_utc_date_time.v": 1], name: "attr_utc_date_time.id_1_attr_utc_date_time.v_1"]
    ]

    Mongo.create_indexes(:mongo, "contacts", indexes)
  end

  def down() do
    Mongo.drop_index(:mongo, "contacts", "attr_bigint.id_1_attr_bigint.v_1")
    Mongo.drop_index(:mongo, "contacts", "attr_string.id_1_attr_string.v_1")
    Mongo.drop_index(:mongo, "contacts", "attr_float.id_1_attr_float.v_1")
    Mongo.drop_index(:mongo, "contacts", "attr_decimal.id_1_attr_decimal.v_1")
    Mongo.drop_index(:mongo, "contacts", "attr_utc_date_time.id_1_attr_utc_date_time.v_1")
  end
end
