defmodule GFSMasterServer.Application do
  require Logger
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  def start(_type, _args) do
    children = [
      {Plug.Cowboy, scheme: :http, plug: {Router, [hello: "world"]}, options: [port: 3001]}
    ]

    opts = [strategy: :one_for_one, name: GFSMasterServer.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
