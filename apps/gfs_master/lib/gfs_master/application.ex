defmodule GFSMaster.Application do
  require Logger
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  def start(_type, _args) do
    children = [
      {Plug.Cowboy,
       scheme: :http, plug: {GFSMaster.Router, [hello: "world"]}, options: [port: 3001]},
      {GFSMaster.ETS.Supervisor, name: GFSMaster.ETS.Supervisor}
    ]

    install_db()

    opts = [strategy: :one_for_one, name: GFSMaster.Supervisor]
    Supervisor.start_link(children, opts)
  end

  def install_db() do
    Amnesia.Schema.create()
    Amnesia.start()
    GFSMaster.FileNamespace.create()
    GFSMaster.FileNamespace.wait()
  end
end
