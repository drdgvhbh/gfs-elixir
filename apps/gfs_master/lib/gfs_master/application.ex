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
    chunks_table = :chunks

    children = [
      {
        Plug.Cowboy,
        scheme: :http, plug: {GFSMaster.Router, []}, options: [port: config.port]
      },
      {GFSMaster.ChunkRegistry, name: GFSMaster.ChunkRegistry, chunks_table: chunks_table}
    ]

    install_db()

    opts = [strategy: :one_for_one, name: GFSMaster.Supervisor]
    {:ok, _} = Supervisor.start_link(children, opts)
  end

  @spec install_db :: :ok | {:error, atom} | {:timeout, [atom]}
  def install_db() do
    Amnesia.Schema.create()
    Amnesia.start()
    GFSMaster.Database.create()
    GFSMaster.Database.wait()
  end
end
