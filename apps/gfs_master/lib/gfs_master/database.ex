require Amnesia
require Algae

use Amnesia
use Witchcraft.Arrow
use Witchcraft.Applicative
use Witchcraft.Chain
use Witchcraft.Functor

alias GFSMaster.Namespace

defdatabase GFSMaster.Database do
  deftable FileMetadata, [:id, :is_dir], type: :set do
    @type t :: %FileMetadata{id: String.t(), is_dir: boolean}

    @spec create_file(binary, boolean) :: Algae.Either
    def create_file(path, is_dir) when is_binary(path) and is_boolean(is_dir) do
      Amnesia.transaction do
        path
        |> Namespace.Path.sanitize()
        |> (fn sanitized_path ->
              chain do
                parent_dirs <- get_parent_directories(sanitized_path)
                save(sanitized_path, is_dir, parent_dirs)
              end
            end).()
      end
    end

    defp save(file_path, is_dir, parent_dirs) do
      write = &FileMetadata.write/1
      hash_file_path = &Namespace.Path.hash(&1)

      check_if_file_already_exists = fn file_id ->
        file_metadata = FileMetadata.read(file_id, :read)

        if file_metadata == nil,
          do: Algae.Either.Right.new(),
          else: {:file_already_exists, file_path} |> Algae.Either.Left.new()
      end

      check_if_parent_is_a_dir = fn _ ->
        Enum.filter(parent_dirs, fn {parent, _} -> parent.is_dir === false end)
        |> Enum.map(fn {_, path} -> path end)
        |> (fn files ->
              if length(files) === 0,
                do: Algae.Either.Right.new(),
                else: {:parents_are_not_directories, files} |> Algae.Either.Left.new()
            end).()
      end

      file_path
      |> hash_file_path.()
      |> (fn file_id ->
            check_if_file_already_exists.(file_id) >>>
              check_if_parent_is_a_dir >>>
              fn _ -> %FileMetadata{id: file_id, is_dir: is_dir} |> Algae.Either.Right.new() end
          end).()
      ~> write
    end

    defp get_parent_directories(path) do
      hash = &Namespace.Path.hash/1
      read = &FileMetadata.read(&1, :read)

      read_parent_metadata =
        &Enum.map(&1, fn parent_path ->
          parent_path |> hash.() |> read.() |> (fn metadata -> {metadata, parent_path} end).()
        end)

      split_missing_parent_metadata =
        &Enum.split_with(&1, fn {metadata, _} -> metadata == nil end)

      map_missing_parent_metadata_to_error = fn {missing_parents, parents} ->
        errs = Enum.map(missing_parents, fn {_, parent_dir} -> parent_dir end)

        if length(errs) === 0,
          do: parents |> Algae.Either.Right.new(),
          else: {:missing_parents_dirs, errs} |> Algae.Either.Left.new()
      end

      path
      |> Namespace.Path.list_parent_paths()
      |> (fn parent_paths ->
            read_parent_metadata.(parent_paths)
            |> split_missing_parent_metadata.()
            |> map_missing_parent_metadata_to_error.()
          end).()
    end
  end

  deftable WorkerNode, [:host_name, :timestamp], type: :set do
    @type t :: %WorkerNode{host_name: Atom.t(), timestamp: String.t()}

    @spec connect_worker(Atom.t()) :: :ok | :error
    def connect_worker(host_name) do
      Amnesia.transaction do
        if WorkerNode.read(host_name, :read) == nil do
          WorkerNode.write(%WorkerNode{
            host_name: host_name,
            timestamp: Time.utc_now() |> Time.to_string()
          })

          :ok
        else
          :error
        end
      end
    end

    @spec disconnect_worker(Atom.t()) :: :ok | :error
    def disconnect_worker(host_name) do
      Amnesia.transaction do
        WorkerNode.delete(host_name)
      end
    end

    @spec list_workers :: [String.t()]
    def list_workers() do
      Amnesia.transaction do
        WorkerNode.keys()
      end
    end
  end
end
