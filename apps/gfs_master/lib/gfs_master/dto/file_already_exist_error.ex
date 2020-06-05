defmodule GFSMaster.DTO.FileAlreadyExistError do
  require Protocol

  @type t :: %__MODULE__{}

  @default_err_msg "file already exists"

  @derive Jason.Encoder
  defstruct error: %{message: "", file_path: ""}

  @spec new :: GFSMaster.DTO.FileAlreadyExistError.t()
  def new() do
    %GFSMaster.DTO.FileAlreadyExistError{error: %{message: @default_err_msg, errors: ""}}
  end

  @spec new(binary) :: GFSMaster.DTO.FileAlreadyExistError.t()
  def new(file_path) when is_binary(file_path) do
    %GFSMaster.DTO.FileAlreadyExistError{
      error: %{message: @default_err_msg, file_path: file_path}
    }
  end

  @spec new(binary, binary) :: GFSMaster.DTO.FileAlreadyExistError.t()
  def new(message, file_path) when is_binary(message) and is_binary(file_path) do
    %GFSMaster.DTO.FileAlreadyExistError{error: %{message: message, file_path: file_path}}
  end
end
