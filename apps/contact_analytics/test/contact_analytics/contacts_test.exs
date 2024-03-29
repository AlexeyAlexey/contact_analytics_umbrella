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

      assert {:ok, %{_id: %BSON.ObjectId{value: <<_::96>>}}} = Contacts.create_contact(%{"app_id" => c.app_id,
                                                                                         "attrs" => %{bigint_id => 12345,
                                                                                                      string_id => "string value"}})
    end

    # test "failed when not existing attributes", c do
    #   {:ok, %{id: bigint_id}} = CustomAttrs.create_custom_attr(%{app_id: c.app_id,
    #                                                              name: "Test bigint",
    #                                                              data_type: "bigint"})

    #   {:ok, %{id: string_id}} = CustomAttrs.create_custom_attr(%{app_id: c.app_id,
    #                                                              name: "Test string",
    #                                                              data_type: "string"})

    #    assert {:error, _} = Contacts.create_contact(%{"app_id" => c.app_id,
    #                                                   "attrs" => %{ bigint_id => "uuu",
    #                                                                 12345 => 12345,
    #                                                                 "kjk" => 12345,
    #                                                                 string_id => "string value"}})
    #   # {:error,
    #   #  %{
    #   #    "app_id" => #BSON.ObjectId<65eef16b74b5654499153a6c>,
    #   #    "attrs" => %{
    #   #      1 => "uuu",
    #   #      2 => "string value",
    #   #      12345 => 12345,
    #   #      "kjk" => {:errors, ["kjk", "key is not an integer", 12345]}
    #   #    }
    #   #  }}
    # end

    # test "default values", c do
    #   {:ok, %{id: bigint_id}} = CustomAttrs.create_custom_attr(%{app_id: c.app_id,
    #                                                              name: "Test bigint",
    #                                                              data_type: "bigint"})

    #   {:ok, %{id: string_id}} = CustomAttrs.create_custom_attr(%{app_id: c.app_id,
    #                                                              name: "Test string",
    #                                                              data_type: "string"})

    #  {:ok, %{_id: doc_id}} = Contacts.create_contact(%{"app_id" => c.app_id,
    #                                                    "attrs" => %{bigint_id => 12345,
    #                                                                 string_id => "string value"}})

    #  %Mongo.Stream{docs: [doc | _]} = Mongo.find(:mongo, Contact.collection_name, %{app_id: c.app_id, _id: doc_id})


    #  assert [%{"id" => ^bigint_id, "v" => _, "up_at" => %DateTime{}}] = doc["attr_bigint"]
    #  assert [%{"id" => ^string_id, "v" => _, "up_at" => %DateTime{}}] = doc["attr_string"]
    # end
  end

  describe "creating contacts" do
    test "", c do
      {:ok, %{id: bigint_id}} = CustomAttrs.create_custom_attr(%{app_id: c.app_id,
                                                                 name: "Test bigint",
                                                                 data_type: "bigint"})

      {:ok, %{id: string_id}} = CustomAttrs.create_custom_attr(%{app_id: c.app_id,
                                                                 name: "Test string",
                                                                 data_type: "string"})

      # [_validated_docs,
      #  _not_validated_docs,
      #  _failed_params_format] = CustomAttrs.Docs.convert_validate(c.app_id, [%{"app_id" => c.app_id,
      #                                                                         "attrs" => %{ bigint_id => "eeeee",
      #                                                                                       string_id => "123456",
      #                                                                                       "1234567" => 12345678 }},
      #                                                                       %{"app_id" => c.app_id,
      #                                                                         "attrs" => %{ bigint_id => 123333,
      #                                                                                       string_id => "123456" }}])
     docs = [%{"app_id" => c.app_id,
               "attrs" => %{bigint_id => 12345,
                            string_id => "string value"}},
             %{"app_id" => c.app_id,
               "attrs" => %{bigint_id => 098765,
                            string_id => "email@mail.com"}}]

     res = Contacts.create_contacts(c.app_id, docs)


     IO.inspect(res)
     # res = Contacts.create_contacts(app_id: c.app_id, [%{atrs: %{ bigint_id => 12345,
     #                                                              string_id => "123456",
     #                                                              "1234567" => 12345678 }}])

     # %{app_id: c.app_id,
     #                                          attr_bigint: [%{id: bigint_id, v: 12345},
     #                                                        %{id: 12345, v: 12345}],
     #                                          attr_string: [%{id: string_id, v: "string value"}]}

     # %Mongo.Stream{docs: [doc | _]} = Mongo.find(:mongo, Contact.collection_name, %{app_id: c.app_id, _id: doc_id})

     # assert [%{"id" => bigint_id, "v" => _, "in_at" => %DateTime{}, "up_at" => %DateTime{}}] = doc["attr_bigint"]
     # assert [%{"id" => string_id, "v" => _, "in_at" => %DateTime{}, "up_at" => %DateTime{}}] = doc["attr_string"]
    end
  end
end
