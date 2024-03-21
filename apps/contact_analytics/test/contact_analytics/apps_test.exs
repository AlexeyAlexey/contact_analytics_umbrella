# defmodule ContactAnalytics.AppsTest do
#   use ContactAnalytics.DataCase

#   alias ContactAnalytics.Apps

#   describe "aplications" do
#     alias ContactAnalytics.Apps.App

#     import ContactAnalytics.AppsFixtures

#     @invalid_attrs %{}

#     test "list_aplications/0 returns all aplications" do
#       app = app_fixture()
#       assert Apps.list_aplications() == [app]
#     end

#     test "get_app!/1 returns the app with given id" do
#       app = app_fixture()
#       assert Apps.get_app!(app.id) == app
#     end

#     test "create_app/1 with valid data creates a app" do
#       valid_attrs = %{}

#       assert {:ok, %App{} = app} = Apps.create_app(valid_attrs)
#     end

#     test "create_app/1 with invalid data returns error changeset" do
#       assert {:error, %Ecto.Changeset{}} = Apps.create_app(@invalid_attrs)
#     end

#     test "update_app/2 with valid data updates the app" do
#       app = app_fixture()
#       update_attrs = %{}

#       assert {:ok, %App{} = app} = Apps.update_app(app, update_attrs)
#     end

#     test "update_app/2 with invalid data returns error changeset" do
#       app = app_fixture()
#       assert {:error, %Ecto.Changeset{}} = Apps.update_app(app, @invalid_attrs)
#       assert app == Apps.get_app!(app.id)
#     end

#     test "delete_app/1 deletes the app" do
#       app = app_fixture()
#       assert {:ok, %App{}} = Apps.delete_app(app)
#       assert_raise Ecto.NoResultsError, fn -> Apps.get_app!(app.id) end
#     end

#     test "change_app/1 returns a app changeset" do
#       app = app_fixture()
#       assert %Ecto.Changeset{} = Apps.change_app(app)
#     end
#   end
# end
