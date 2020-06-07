defmodule GFSChunk.Worker do
  use GenServer

  @impl true
  def init(opts) do
    master_hostname = Keyword.fetch!(opts, :master_hostname) |> String.to_atom()
    rack_id = Keyword.fetch!(opts, :rack_id)

    {_, total_kb, percentage_used} =
      :disksup.get_disk_data()
      |> Enum.find(nil, fn {path, _, _} -> path === '/' end)

    kb_used = (total_kb * (percentage_used / 100.0)) |> Kernel.trunc()

    :pong = Node.ping(master_hostname)

    :ok =
      GenServer.call(
        {GFSMaster.ChunkRegistry, master_hostname},
        {:connect, Node.self(), rack_id, kb_used}
      )

    {:ok, opts}
  end

  def start_link(opts) do
    GenServer.start_link(__MODULE__, opts, name: __MODULE__)
  end
end
