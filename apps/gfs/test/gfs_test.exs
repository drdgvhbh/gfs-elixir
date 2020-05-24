defmodule GFSTest do
  use ExUnit.Case
  doctest GFS

  test "greets the world" do
    assert GFS.hello() == :world
  end
end
