defmodule ContactAnalytics.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      {DNSCluster, query: Application.get_env(:contact_analytics, :dns_cluster_query) || :ignore},
      {Phoenix.PubSub, name: ContactAnalytics.PubSub},
      # Start the Finch HTTP client for sending emails
      {Finch, name: ContactAnalytics.Finch},
      # Start a worker by calling: ContactAnalytics.Worker.start_link(arg)
      # {ContactAnalytics.Worker, arg}
      {Mongo, ContactAnalytics.Repo.config()}
    ]

    Supervisor.start_link(children, strategy: :one_for_one, name: ContactAnalytics.Supervisor)
  end
end
