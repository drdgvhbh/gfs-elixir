defmodule GFSMaster.DTO.ParentsAreNotDirectoriesError do
  require Protocol

  @type t :: %__MODULE__{}

  @default_err_msg "the parents of this file must all be directories"

  @derive Jason.Encoder
  defstruct error: %{message: "", invalid_directories: []}

  @spec new :: GFSMaster.DTO.ParentsAreNotDirectoriesError.t()
  def new() do
    %GFSMaster.DTO.ParentsAreNotDirectoriesError{
      error: %{message: @default_err_msg, invalid_directories: []}
    }
  end

  @spec new(String.t() | List[any()]) :: GFSMaster.DTO.ParentsAreNotDirectoriesError.t()
  def new(message) when is_binary(message) do
    %GFSMaster.DTO.ParentsAreNotDirectoriesError{
      error: %{message: message, invalid_directories: []}
    }
  end

  def new(invalid_directories) when is_list(invalid_directories) do
    %GFSMaster.DTO.ParentsAreNotDirectoriesError{
      error: %{message: @default_err_msg, invalid_directories: invalid_directories}
    }
  end

  @spec new(binary, list()) :: GFSMaster.DTO.ParentsAreNotDirectoriesError.t()
  def new(message, invalid_directories)
      when is_binary(message) and is_list(invalid_directories) do
    %GFSMaster.DTO.ParentsAreNotDirectoriesError{
      error: %{message: message, invalid_directories: invalid_directories}
    }
  end
end
