defmodule ContactAnalytics.Repo do
  use Mongo.Repo,
    otp_app: :contact_analytics,
    topology: :mongo
end
