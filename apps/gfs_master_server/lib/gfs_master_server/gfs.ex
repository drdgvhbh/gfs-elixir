defmodule GFS do
  require Logger

  def create(nil), do: :error

  # Drops "" paths from the head of the list
  @spec drop_empty_paths(list(String.t())) :: list(String.t())
  defp drop_empty_paths(path_hierarchy) do
    Enum.drop_while(path_hierarchy, fn path -> path == "" end)
  end

  @spec separate_paths(list(String.t())) :: {String.t(), list(String.t())}
  defp separate_paths(paths) do
    List.pop_at(paths, -1)
    |> (fn {file_name, directories} ->
          {file_name, drop_empty_paths(directories)}
        end).()
  end

  @spec create(String.t(), any()) :: :ok
  def create(path, file_namespace) do
    if :digraph_utils.is_tree(file_namespace) do
      {file_name, directories} = separate_paths(String.split(path, "/"))

      {:yes, root} = :digraph_utils.arborescence_root(file_namespace)

      cwd =
        List.foldl(directories, root, fn directory, current_node ->
          :digraph.edges(file_namespace, current_node)
          |> (fn edges ->
                if length(edges) > 0 do
                  subdirectory =
                    Enum.filter(edges, fn edge ->
                      :digraph.edge(file_namespace, edge)
                      |> (fn {_, _, _, edge_label} -> edge_label === directory end).()
                    end)
                    |> (fn filtered_edges ->
                          Enum.map(filtered_edges, fn {_, _, subdirectory, _} -> subdirectory end)
                        end).()
                    |> List.first()

                  subdirectory
                else
                  nil
                end
              end).()
        end)

      cwd |> IO.inspect()

      :ok
    else
      :error
    end
  end
end
