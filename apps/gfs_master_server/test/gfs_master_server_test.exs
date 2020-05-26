defmodule GFSMasterServerTest do
  use ExUnit.Case
  doctest GFSMasterServer

  test "greets the world" do
    assert GFSMasterServer.hello() == :world
  end
end
