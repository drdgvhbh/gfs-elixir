defmodule GFSMaster.Registry do
  use GenServer

  @impl true
  def init(_) do
    file_namespace =
      :ets.new(
        :file_namespace,
        [:named_table, :public, read_concurrency: true, write_concurrency: true]
      )

    {:ok, {file_namespace}}
  end

  def start_link(opts) do
    server = Keyword.fetch!(opts, :name)
    GenServer.start_link(__MODULE__, server, opts)
  end
end
