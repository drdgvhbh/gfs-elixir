defmodule GFSServerTest do
  use ExUnit.Case
  doctest GFSServer

  test "greets the world" do
    assert GFSServer.hello() == :world
  end
end
