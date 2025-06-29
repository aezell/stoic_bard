defmodule StoicBard.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    # Load environment variables from .env file in development
    if Application.get_env(:stoic_bard, :env) == :dev do
      Envy.auto_load()
    end

    children = [
      StoicBardWeb.Telemetry,
      {DNSCluster, query: Application.get_env(:stoic_bard, :dns_cluster_query) || :ignore},
      {Phoenix.PubSub, name: StoicBard.PubSub},
      # Start the Finch HTTP client for sending emails
      {Finch, name: StoicBard.Finch},
      # Start a worker by calling: StoicBard.Worker.start_link(arg)
      # {StoicBard.Worker, arg},
      # Start to serve requests, typically the last entry
      StoicBardWeb.Endpoint
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: StoicBard.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    StoicBardWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
