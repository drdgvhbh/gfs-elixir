defmodule GFSMaster.Controller do
  require Logger

  def create(nil), do: :error

  def create2(path, table) do
    file_list = path |> String.split("/") |> drop_empty_paths

    hash = fn p -> :crypto.hash(:sha, p) |> Base.encode16() end

    parent_directories =
      file_list
      |> List.delete_at(-1)
      |> build_parent_directories
      |> drop_empty_paths
      |> Enum.map(hash)

    sanitized_path = file_list |> Enum.join("/") |> hash.()

    parent_directories |> IO.inspect()
    sanitized_path |> IO.inspect()

    GFSMaster.FileNamespace.FileMetadata.create_file(sanitized_path, false)

    # parent_directories
    # |> Enum.each(fn parent_directory ->
    #   parent_directory |> IO.inspect()
    #   :ets.lookup(table, parent_directory) |> IO.inspect()
    #   true = GFS.Metadata.lock(table, parent_directory, :read)
    # end)
    #
    # true = :ets.insert_new(table, {sanitized_path, false, false})
    # sanitized_path |> IO.inspect()
    #
    # Enum.reverse(parent_directories)
    # |> Enum.each(fn parent_directory ->
    #   true = GFS.Metadata.unlock(table, parent_directory)
    # end)
  end

  @spec create(String.t(), any()) :: :ok
  def create(path, file_namespace) do
    # if :digraph_utils.is_tree(file_namespace) do
    #   file_list = path |> String.split("/") |> drop_empty_paths
    #   {file_name, directory_list} = separate_paths(file_list)
    #
    #   {:yes, root} = :digraph_utils.arborescence_root(file_namespace)
    #
    #   cwd = getCurrentWorkingDirectory(directory_list, file_namespace, root)
    #
    #   if cwd != nil do
    #     cwd |> IO.inspect()
    #     :ok
    #   else
    #     :error
    #   end
    # else
    #   :error
    # end
  end

  # Drops "" paths from the head of the list
  @spec drop_empty_paths([String.t()]) :: [String.t()]
  defp drop_empty_paths(path_hierarchy) do
    Enum.drop_while(path_hierarchy, fn path -> path == "" end)
  end

  defp build_parent_directories(paths) do
    Enum.map(0..(length(paths) - 1), fn i ->
      Enum.slice(paths, 0..i) |> Enum.join("/")
    end)
  end

  @spec getCurrentWorkingDirectory([String.t()], any, any) :: any
  defp getCurrentWorkingDirectory(directory_list, file_namespace, root) do
    List.foldl(directory_list, root, fn directory, current_node ->
      :digraph.edges(file_namespace, current_node)
      |> (fn edges ->
            if length(edges) > 0 do
              subdirectory =
                Enum.map(edges, fn edge -> :digraph.edge(file_namespace, edge) end)
                |> (fn mapped_edges ->
                      Enum.filter(mapped_edges, fn {_, _, _, edge_label} ->
                        edge_label === directory
                      end)
                    end).()
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
  end
end
