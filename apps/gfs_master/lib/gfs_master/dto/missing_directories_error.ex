defmodule GFSMaster.DTO.MissingDirectoriesError do
  require Protocol

  @type t :: %__MODULE__{}

  @default_err_msg "file is missing parent directories"

  @derive Jason.Encoder
  defstruct error: %{message: "", missing_directories: []}

  @spec new :: GFSMaster.DTO.MissingDirectoriesError.t()
  def new() do
    %GFSMaster.DTO.MissingDirectoriesError{
      error: %{message: @default_err_msg, missing_directories: []}
    }
  end

  @spec new(String.t() | List[any()]) :: GFSMaster.DTO.MissingDirectoriesError.t()
  def new(message) when is_binary(message) do
    %GFSMaster.DTO.MissingDirectoriesError{
      error: %{message: message, missing_directories: []}
    }
  end

  def new(missing_directories) when is_list(missing_directories) do
    %GFSMaster.DTO.MissingDirectoriesError{
      error: %{message: @default_err_msg, missing_directories: missing_directories}
    }
  end

  @spec new(binary, list()) :: GFSMaster.DTO.MissingDirectoriesError.t()
  def new(message, missing_directories)
      when is_binary(message) and is_list(missing_directories) do
    %GFSMaster.DTO.MissingDirectoriesError{
      error: %{message: message, missing_directories: missing_directories}
    }
  end
end
