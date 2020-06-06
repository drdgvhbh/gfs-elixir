defmodule GFSMaster.Namespace.Path do
  @spec sanitize(String.t()) :: String.t()
  def sanitize(path) do
    Path.relative(path)
  end

  @spec hash(String.t()) :: String.t()
  def hash(path) do
    :crypto.hash(:sha, path) |> Base.encode16() |> to_string
  end

  @spec list_parent_paths(String.t()) :: [String.t()]
  def list_parent_paths(path) do
    path
    |> Path.split()
    |> (fn paths ->
          if length(paths) <= 1,
            do: [],
            else: Enum.map(0..(length(paths) - 2), &Enum.slice(paths, 0..&1))
        end).()
    |> Enum.map(fn segment -> Enum.join(segment, "/") end)
  end
end
