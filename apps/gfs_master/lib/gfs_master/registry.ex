defmodule GFSMaster.Registry do
  use GenServer

  @impl true
  @spec init(any) :: {:ok, {}}
  def init(_) do
    {:ok, {}}
  end

  def start_link(opts) do
    server = Keyword.fetch!(opts, :name)
    GenServer.start_link(__MODULE__, server, opts)
  end
end
