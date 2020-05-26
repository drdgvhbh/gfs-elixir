defmodule GFSServer.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  def start(_type, _args) do
    port = String.to_integer(System.get_env("PORT") || "4041")

    children = [
      # Starts a worker by calling: GFSServer.Worker.start_link(arg)
      # {GFSServer.Worker, arg}
      {Task.Supervisor, name: GFSServer.TaskSupervisor},
      Supervisor.child_spec({Task, fn -> GFSServer.accept(port) end}, restart: :permanent)
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: GFSServer.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
