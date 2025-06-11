defmodule Core.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      CoreWeb.Telemetry,
      Core.Repo,
      {DNSCluster, query: Application.get_env(:core, :dns_cluster_query) || :ignore},
      {Phoenix.PubSub, name: Core.PubSub},
      # Start the Finch HTTP client for sending emails
      {Finch, name: Core.Finch},
      # Start a worker by calling: Core.Worker.start_link(arg)
      # {Core.Worker, arg},
      # Start to serve requests, typically the last entry
      CoreWeb.Endpoint
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Core.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    CoreWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
