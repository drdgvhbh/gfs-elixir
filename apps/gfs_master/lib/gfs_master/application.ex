defmodule GFSMaster.Application do
  require Logger
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  alias Vapor.Provider.{Env, Dotenv}

  def start(_type, _args) do
    providers = [
      %Dotenv{},
      %Env{bindings: [{:port, "PORT", map: &String.to_integer/1, default: 3000, required: true}]}
    ]

    config = Vapor.load!(providers)

    children = [
      {
        Plug.Cowboy,
        scheme: :http, plug: {GFSMaster.Router, []}, options: [port: config.port]
      },
      {GFSMaster.ChunkRegistry, name: GFSMaster.ChunkRegistry}
    ]

    :stopped = Amnesia.stop()
    # :ok = Amnesia.Schema.create([Node.self(), :"retards@127.0.0.1"])
    :ok = Amnesia.start()
    GFSMaster.Database.create(disk: [Node.self()])
    :ok = GFSMaster.Database.wait(15000)
    # :ok = Amnesia.start()
    # GFSMaster.Database.create()
    # :ok = GFSMaster.Database.wait(15000)

    opts = [strategy: :one_for_one, name: GFSMaster.Supervisor]
    {:ok, _} = Supervisor.start_link(children, opts)
  end
end
