defmodule ContactAnalytics.CustomAttrsTest do
  # use ContactAnalytics.DataCase
  use ExUnit.Case

  alias ContactAnalytics.CustomAttrs
  alias ContactAnalytics.CustomAttrs.CustomAttr

  setup do
    # assert {:ok, pid} = ContactAnalytics.MongoTestConnection.connect()
    # assert {:ok, pid} = start_supervised!({Mongo, ContactAnalytics.Repo.config()})
    Mongo.drop_database(:mongo, nil, w: 3)
    {:ok, app_id} = BSON.ObjectId.decode("65eef16b74b5654499153a6c")

    {:ok, [app_id: app_id]}
  end

  describe "" do
    test "" do
      assert [] = Mongo.find(:mongo, CustomAttr.collection_name, %{}) |> Enum.to_list()
    end
  end

  describe "list/1" do
    import ContactAnalytics.CustomAttrsFixtures

    test "default attrs", c do
      custom_attr_fixture(%{app_id: c.app_id})

      assert CustomAttrs.list(%{app_id: c.app_id}) == Mongo.find(:mongo, CustomAttr.collection_name, %{app_id: c.app_id}) |> Enum.to_list()
    end

    test "limit parameter", c do
      custom_attr_fixture(%{app_id: c.app_id})

      assert Mongo.find(:mongo, CustomAttr.collection_name, %{app_id: c.app_id}) |> Enum.count() == 2
      assert CustomAttrs.list(%{app_id: c.app_id, limit: 1}) |> Enum.count() == 1
    end
  end

  describe "create_custom_attr/1" do
    test "creating", c do
      app_id = c.app_id
      assert {:ok, %{id: _,
                     name: "test name",
                     data_type: "bigint",
                     _id: _,
                     app_id: ^app_id,
                     inserted_at: _,
                     updated_at: _,
                     deleted: false}} = CustomAttrs.create_custom_attr(%{app_id: app_id, name: "test name", data_type: "bigint"})
    end
  end

  describe "update_by_id/1" do
    import ContactAnalytics.CustomAttrsFixtures

    test "updating name", c do
      custom_attr_fixture(%{app_id: c.app_id})

      first = Mongo.find_one(:mongo, CustomAttr.collection_name, %{})

      id = first["_id"]

      new_name = "Updated Name"

      {:ok, value} = CustomAttrs.update_by_id(id, c.app_id, %{name: new_name})

      assert %{"_id" => %BSON.ObjectId{value: <<_::96>>}} = value
      assert first["name"] != new_name
      assert %{"name" => ^new_name} = Mongo.find_one(:mongo, CustomAttr.collection_name, %{"_id" => id})
    end
  end

  # describe "custom_attrs" do
    

  #   import ContactAnalytics.CustomAttrsFixtures

  #   @invalid_attrs %{}

  #   test "list_custom_attrs/0 returns all custom_attrs" do
  #     custom_attr = custom_attr_fixture()
  #     assert CustomAttrs.list_custom_attrs() == [custom_attr]
  #   end

  #   test "get_custom_attr!/1 returns the custom_attr with given id" do
  #     custom_attr = custom_attr_fixture()
  #     assert CustomAttrs.get_custom_attr!(custom_attr.id) == custom_attr
  #   end

  #   test "create_custom_attr/1 with valid data creates a custom_attr" do
  #     valid_attrs = %{}

  #     assert {:ok, %CustomAttr{} = custom_attr} = CustomAttrs.create_custom_attr(valid_attrs)
  #   end

  #   test "create_custom_attr/1 with invalid data returns error changeset" do
  #     assert {:error, %Ecto.Changeset{}} = CustomAttrs.create_custom_attr(@invalid_attrs)
  #   end

  #   test "update_custom_attr/2 with valid data updates the custom_attr" do
  #     custom_attr = custom_attr_fixture()
  #     update_attrs = %{}

  #     assert {:ok, %CustomAttr{} = custom_attr} = CustomAttrs.update_custom_attr(custom_attr, update_attrs)
  #   end

  #   test "update_custom_attr/2 with invalid data returns error changeset" do
  #     custom_attr = custom_attr_fixture()
  #     assert {:error, %Ecto.Changeset{}} = CustomAttrs.update_custom_attr(custom_attr, @invalid_attrs)
  #     assert custom_attr == CustomAttrs.get_custom_attr!(custom_attr.id)
  #   end

  #   test "delete_custom_attr/1 deletes the custom_attr" do
  #     custom_attr = custom_attr_fixture()
  #     assert {:ok, %CustomAttr{}} = CustomAttrs.delete_custom_attr(custom_attr)
  #     assert_raise Ecto.NoResultsError, fn -> CustomAttrs.get_custom_attr!(custom_attr.id) end
  #   end

  #   test "change_custom_attr/1 returns a custom_attr changeset" do
  #     custom_attr = custom_attr_fixture()
  #     assert %Ecto.Changeset{} = CustomAttrs.change_custom_attr(custom_attr)
  #   end
  # end
end
