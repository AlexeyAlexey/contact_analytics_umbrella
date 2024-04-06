defmodule ContactAnalytics.ContactsTest do
  use ExUnit.Case

  alias ContactAnalytics.Contacts
  alias ContactAnalytics.Contacts.Contact
  alias ContactAnalytics.CustomAttrs

  setup do
    Mongo.drop_database(:mongo, nil, w: 3)
    {:ok, app_id} = BSON.ObjectId.decode("65eef16b74b5654499153a6c")

    {:ok, [app_id: app_id]}
  end

  describe "creating a contact" do
    test "", c do
      {:ok, %{id: bigint_id}} = CustomAttrs.create_custom_attr(%{app_id: c.app_id,
                                                                 name: "Test bigint",
                                                                 data_type: "bigint"})

      {:ok, %{id: string_id}} = CustomAttrs.create_custom_attr(%{app_id: c.app_id,
                                                                 name: "Test string",
                                                                 data_type: "string"})

      [valid_attrs_doc,
       _invalid_attrs_doc,
       _failed_attrs_format] = CustomAttrs.Docs.convert_validate_doc(%{"attrs" => %{bigint_id => 12345,
                                                                                    string_id => "string value"}}, c.app_id)

      assert {:ok, %{_id: %BSON.ObjectId{value: <<_::96>>}}} = Contacts.create_contact(valid_attrs_doc, c.app_id)
    end
  end

  describe "creating contacts" do
    test "", c do
     {:ok, %{id: bigint_id}} = CustomAttrs.create_custom_attr(%{app_id: c.app_id,
                                                                 name: "Test bigint",
                                                                 data_type: "bigint"})

      {:ok, %{id: string_id}} = CustomAttrs.create_custom_attr(%{app_id: c.app_id,
                                                                 name: "Test string",
                                                                 data_type: "string"})


     docs = [%{"attrs" => %{bigint_id => 12345,
                            string_id => "string value"}},
             %{"attrs" => %{bigint_id => 098765,
                            string_id => "email@mail.com"}}]

     [valid_attrs_docs,
      _invalid_attrs_docs,
      _failed_attrs_format] = CustomAttrs.Docs.convert_validate(docs, c.app_id)

     [ids, errors, invalid_docs] = Contacts.create_contacts(valid_attrs_docs, c.app_id)

     assert [%BSON.ObjectId{value: <<_::96>>}, %BSON.ObjectId{value: <<_::96>>}] = ids
     assert [] == errors
     assert [] == invalid_docs
    end
  end
end
