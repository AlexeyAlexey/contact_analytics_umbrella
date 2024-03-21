defmodule ContactAnalytics.Apps.App do
  @moduledoc false
  use Mongo.Collection

  collection :apps do
    attribute :name, String.t()
    attribute :email, String.t()

    timestamps()
  end
end
