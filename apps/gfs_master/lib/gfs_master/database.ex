require Amnesia
use Amnesia

defdatabase GFSMaster.FileNamespace do
  deftable FileMetadata, [:id, :is_dir], type: :set do
    @type t :: %FileMetadata{id: String.t(), is_dir: boolean}

    @spec create_file(binary, boolean) :: :ok
    def create_file(file_path, is_dir) when is_binary(file_path) and is_boolean(is_dir) do
      id = hash(file_path)

      Amnesia.transaction do
        %FileMetadata{id: id, is_dir: is_dir} |> FileMetadata.write()
      end

      :ok
    end

    defp hash(text) do
      :crypto.hash(:sha, text) |> Base.encode16()
    end
  end
end
