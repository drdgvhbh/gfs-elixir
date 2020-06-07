defmodule GFSMaster.ChunkRegistry do
  use GenServer

  @impl true
  def init(opts) do
    {:ok, {opts}}
  end

  def start_link(opts) do
    GenServer.start_link(__MODULE__, opts, name: __MODULE__)
  end

  @impl true
  def handle_call({:connect, host_name}, _from, state) do
    Node.monitor(host_name, true)

    case host_name
         |> Atom.to_string()
         |> GFSMaster.Database.WorkerNode.connect_worker() do
      :ok -> {:reply, :ok, state}
      :error -> {:reply, :error, state}
    end
  end

  @impl true
  def handle_info({:nodedown, host_name}, state) do
    host_name
    |> Atom.to_string()
    |> GFSMaster.Database.WorkerNode.disconnect_worker()

    {:noreply, state}
  end
end
