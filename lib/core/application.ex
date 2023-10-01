defmodule Core.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      # Start the Telemetry supervisor
      CoreWeb.Telemetry,
      # Start the Ecto repository
      Core.Repo,
      # Start the PubSub system
      {Phoenix.PubSub, name: Core.PubSub},
      # Start Finch
      {
        Finch,
        name: Core.Finch
      },
      # Start the Endpoint (http/https)
      CoreWeb.Endpoint,
      # Start the Presence tracker
      CoreWeb.Channels.Presence

      # Start a worker by calling: Core.Worker.start_link(arg)
      # {Core.Worker, arg}
    ]

    # In HTTP Responses use the Server-Timing spec to tell us response times
    Plug.Telemetry.ServerTiming.install([
      {[:phoenix, :endpoint, :stop], :duration, description: ~s("Endpoint Duration")},
      {[:phoenix, :router_dispatch, :stop], :duration, description: ~s("Router Duration")},
      {[:phoenix, :live_view, :mount, :stop], :duration,
       description: ~s("LiveView Mount Duration")},
      {[:core, :repo, :query], :total_time, description: ~s("Ecto Query Total Time")},
      {[:core, :repo, :query], :decode_time, description: ~s("Ecto Query Decode Time")},
      {[:core, :repo, :query], :query_time, description: ~s("Ecto Query Query Time")},
      {[:core, :repo, :query], :queue_time, description: ~s("Ecto Query Queue Time")},
      {[:core, :repo, :query], :idle_time, description: ~s("Ecto Query Idle Time")}
    ])

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
