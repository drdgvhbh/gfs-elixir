defmodule GFSChunk.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  alias Vapor.Provider.{Env, Dotenv}

  def start(_type, _args) do
    providers = [
      %Dotenv{},
      %Env{
        bindings: [
          {:master_hostname, "MASTER_HOSTNAME", required: true},
          {:rack_id, "RACK_ID", required: true}
        ]
      }
    ]

    :disksup.start_link()
    :disksup.set_check_interval(1)

    config = Vapor.load!(providers)

    children = [
      # Starts a worker by calling: GFSChunk.Worker.start_link(arg)
      # {GFSChunk.Worker, arg}
      {GFSChunk.Worker,
       name: GFSChunk.Worker, master_hostname: config.master_hostname, rack_id: config.rack_id}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: GFSChunk.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
