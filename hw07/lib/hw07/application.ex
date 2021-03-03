defmodule Hw07.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  def start(_type, _args) do
    children = [
      # Start the Ecto repository
      Hw07.Repo,
      # Start the Telemetry supervisor
      Hw07Web.Telemetry,
      # Start the PubSub system
      {Phoenix.PubSub, name: Hw07.PubSub},
      # Start the Endpoint (http/https)
      Hw07Web.Endpoint
      # Start a worker by calling: Hw07.Worker.start_link(arg)
      # {Hw07.Worker, arg}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Hw07.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  def config_change(changed, _new, removed) do
    Hw07Web.Endpoint.config_change(changed, removed)
    :ok
  end
end
