defmodule GFSMaster.ChunkRegistry do
  use GenServer

  @impl true
  @spec init(keyword) :: {:ok, {atom | :ets.tid()}}
  def init(opts) do
    chunks_table = Keyword.fetch!(opts, :chunks_table)
    ^chunks_table = :ets.new(chunks_table, [:set, :protected, :named_table])

    {:ok, {chunks_table}}
  end

  def start_link(opts) do
    GenServer.start_link(__MODULE__, opts, name: __MODULE__)
  end

  @impl true
  def handle_call({:connect, host_name}, _from, state) do
    Node.monitor(host_name, true)

    {chunks_table} = state

    if :ets.insert_new(chunks_table, {host_name}),
      do: {:reply, :ok, state},
      else: {:reply, :error, state}
  end

  @impl true
  def handle_info({:nodedown, host_name}, state) do
    {chunks_table} = state

    :ets.delete(chunks_table, host_name)

    {:noreply, state}
  end
end
