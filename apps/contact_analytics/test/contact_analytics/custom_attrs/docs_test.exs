defmodule ContactAnalytics.CustomAttrs.DocsTest do
  use ExUnit.Case

  alias ContactAnalytics.CustomAttrs

  setup do
    Mongo.drop_database(:mongo, nil, w: 3)
    {:ok, app_id} = BSON.ObjectId.decode("65eef16b74b5654499153a6c")

    {:ok, [app_id: app_id]}
  end

  describe "#convert_validate" do
    test "when docs are valid", c do
      {:ok, %{id: bigint_id}} = CustomAttrs.create_custom_attr(%{app_id: c.app_id,
                                                                 name: "Test bigint",
                                                                 data_type: "bigint"})

      {:ok, %{id: string_id}} = CustomAttrs.create_custom_attr(%{app_id: c.app_id,
                                                                 name: "Test string",
                                                                 data_type: "string"})

      [validated_docs,
       not_validated_docs,
       failed_params_format] = CustomAttrs.Docs.convert_validate([%{"app_id" => c.app_id,
                                                                    "attrs" => %{bigint_id => 12345,
                                                                                 string_id => "string value"}}], c.app_id)

      app_id = c.app_id

      assert [%{"app_id" => ^app_id,
                "attr_bigint" => [%{id: ^bigint_id, v: 12345}],
                "attr_string" => [%{id: ^string_id, v: "string value"}]}] = validated_docs

      assert not_validated_docs == []
      assert failed_params_format == []
    end

    test "when a doc does not have attrs key", c do
      {:ok, %{id: _bigint_id}} = CustomAttrs.create_custom_attr(%{app_id: c.app_id,
                                                                  name: "Test bigint",
                                                                  data_type: "bigint"})

      {:ok, %{id: _string_id}} = CustomAttrs.create_custom_attr(%{app_id: c.app_id,
                                                                  name: "Test string",
                                                                  data_type: "string"})

      [validated_docs,
       not_validated_docs,
       failed_params_format] = CustomAttrs.Docs.convert_validate([%{"app_id" => c.app_id, "name" => "name" }], c.app_id)

      app_id = c.app_id

      assert [%{"app_id" => ^app_id, "name" => "name"}] = validated_docs

      assert not_validated_docs == []
      assert failed_params_format == []
    end

    test "when value attr is invalid", c do
      {:ok, %{id: bigint_id}} = CustomAttrs.create_custom_attr(%{app_id: c.app_id,
                                                                 name: "Test bigint",
                                                                 data_type: "bigint"})

      {:ok, %{id: string_id}} = CustomAttrs.create_custom_attr(%{app_id: c.app_id,
                                                                 name: "Test string",
                                                                 data_type: "string"})

      [validated_docs,
       not_validated_docs,
       failed_params_format] = CustomAttrs.Docs.convert_validate([%{"app_id" => c.app_id,
                                                                    "attrs" => %{bigint_id => "isnotbigint",
                                                                                 string_id => "string value"}}], c.app_id)

      app_id = c.app_id

      assert validated_docs == []
      assert [%{"app_id" => ^app_id,
                "attrs" => %{^bigint_id => {"isnotbigint", [errors: [v: {"is invalid", [type: :integer, validation: :cast]}]]},
                             ^string_id => "string value"}}] = not_validated_docs
      assert failed_params_format == []
    end

    test "when id attr is not integer", c do
      {:ok, %{id: _bigint_id}} = CustomAttrs.create_custom_attr(%{app_id: c.app_id,
                                                                  name: "Test bigint",
                                                                  data_type: "bigint"})

      {:ok, %{id: string_id}} = CustomAttrs.create_custom_attr(%{app_id: c.app_id,
                                                                 name: "Test string",
                                                                 data_type: "string"})

      [validated_docs,
       not_validated_docs,
       failed_params_format] = CustomAttrs.Docs.convert_validate([%{"app_id" => c.app_id,
                                                                    "attrs" => %{"isnotint" => 12345,
                                                                                 string_id => "string value"}}], c.app_id)

      app_id = c.app_id

      assert  [] == validated_docs
      assert  [] == not_validated_docs
      assert [%{"app_id" => ^app_id,
                "attrs" => %{"isnotint" => {12345, [errors: [id: {"is invalid", [type: :integer, validation: :cast]}]]},
                             ^string_id => "string value"}}] = failed_params_format
    end

    test "when id attr does not belong to a data type", c do
      {:ok, %{id: _bigint_id}} = CustomAttrs.create_custom_attr(%{app_id: c.app_id,
                                                                  name: "Test bigint",
                                                                  data_type: "bigint"})

      {:ok, %{id: string_id}} = CustomAttrs.create_custom_attr(%{app_id: c.app_id,
                                                                 name: "Test string",
                                                                 data_type: "string"})

      [validated_docs,
       not_validated_docs,
       failed_params_format] = CustomAttrs.Docs.convert_validate([%{"app_id" => c.app_id,
                                                                    "attrs" => %{1000 => 12345,
                                                                                 string_id => "string value"}}], c.app_id)

      app_id = c.app_id

      assert  [] == validated_docs

      assert  [%{"app_id" => ^app_id,
                 "attrs" => %{1000 => {12345, [errors: [id: {"does not belong to a data type", [type: :integer, validation: :cast]}]]},
                              ^string_id => "string value"}}] = not_validated_docs

      assert [] == failed_params_format
    end

  end
end
