defmodule GFSChunk.Worker do
  use GenServer

  @impl true
  def init(opts) do
    name = Keyword.fetch!(opts, :name)
    master_hostname = Keyword.fetch!(opts, :master_hostname) |> String.to_atom()

    :pong = Node.ping(master_hostname)

    :ok =
      GenServer.call(
        {GFSMaster.ChunkRegistry, master_hostname},
        {:connect, Node.self()}
      )

    {:ok, opts}
  end

  def start_link(opts) do
    GenServer.start_link(__MODULE__, opts, name: __MODULE__)
  end
end
