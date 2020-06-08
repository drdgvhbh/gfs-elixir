defmodule GFSMaster.ChunkRegistry do
  use GenServer

  @impl true
  def init(_) do
    hostname_to_racks = %{}
    hostname_to_psq_key = %{}
    psq_key_counter = 0
    racks = %{}

    {:ok, {racks, hostname_to_racks, hostname_to_psq_key, psq_key_counter}, 0}
  end

  def start_link(opts) do
    GenServer.start_link(__MODULE__, opts, name: __MODULE__)
  end

  @impl true
  def handle_call({:connect, host_name, rack_id, kb_used}, _from, state) do
    Node.monitor(host_name, true)

    psq_key = state |> get_psq_key_counter()

    next_hostname_to_psq_key = state |> get_hostname_to_psq_key() |> Map.put(host_name, psq_key)

    next_racks =
      state
      |> get_racks()
      |> Map.put_new(rack_id, :psq.new())
      |> (fn racks ->
            {racks, Map.get(racks, rack_id)}
          end).()
      |> (fn {racks, psq} ->
            {racks, :psq.insert(psq_key, {kb_used}, nil, psq)}
          end).()
      |> (fn {racks, psq} ->
            Map.put(racks, rack_id, psq)
          end).()

    next_hostname_to_racks =
      state
      |> Kernel.elem(1)
      |> Map.put_new(host_name, rack_id)

    next_counter = (state |> get_psq_key_counter()) + 1

    next_state = {
      next_racks,
      next_hostname_to_racks,
      next_hostname_to_psq_key,
      next_counter
    }

    next_state |> IO.inspect()

    case host_name
         |> GFSMaster.Database.WorkerNode.connect_worker() do
      :ok -> {:reply, :ok, next_state}
      :error -> {:reply, :error, state}
    end
  end

  @impl true
  def handle_info({:nodedown, host_name}, state) do
    next_psq_key_counter = state |> get_psq_key_counter()

    {rack_id, next_hostname_to_racks} =
      state
      |> get_host_name_to_racks()
      |> (fn hostname_to_racks ->
            {Map.get(hostname_to_racks, host_name), Map.delete(hostname_to_racks, host_name)}
          end).()

    {psq_key, next_hostname_to_psq_key} =
      state
      |> get_hostname_to_psq_key()
      |> (fn hostname_to_psq_key ->
            {Map.get(hostname_to_psq_key, host_name), Map.delete(hostname_to_psq_key, host_name)}
          end).()

    next_racks =
      state
      |> get_racks()
      |> (fn racks -> {racks, Map.get(racks, rack_id)} end).()
      |> (fn {racks, psq} -> {racks, :psq.delete(psq_key, psq)} end).()
      |> (fn {racks, psq} -> Map.put(racks, rack_id, psq) end).()

    next_state =
      {next_racks, next_hostname_to_racks, next_hostname_to_psq_key, next_psq_key_counter}

    next_state |> IO.inspect()

    host_name
    |> GFSMaster.Database.WorkerNode.disconnect_worker()

    {:noreply, next_state}
  end

  @impl true
  def handle_info(:timeout, state) do
    GFSMaster.Database.WorkerNode.list_workers()
    |> IO.inspect()
    |> Enum.each(fn worker ->
      worker |> IO.inspect()
      Node.monitor(worker, true)
    end)

    {:noreply, state}
  end

  defp get_racks(state) do
    state |> Kernel.elem(0)
  end

  defp get_host_name_to_racks(state) do
    state |> Kernel.elem(1)
  end

  defp get_hostname_to_psq_key(state) do
    state |> Kernel.elem(2)
  end

  defp get_psq_key_counter(state) do
    state |> Kernel.elem(3)
  end
end
