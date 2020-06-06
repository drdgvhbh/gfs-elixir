defmodule GFSMaster.DTO.ValidationError do
  require Protocol

  @type t :: %__MODULE__{}

  @default_err_msg "schema validation error"

  @derive Jason.Encoder
  defstruct error: %{message: "", errors: []}

  @spec new :: GFSMaster.DTO.ValidationError.t()
  def new() do
    %GFSMaster.DTO.ValidationError{error: %{message: @default_err_msg, errors: []}}
  end

  @spec new(String.t() | List[any()]) :: GFSMaster.DTO.ValidationError.t()
  def new(message) when is_binary(message) do
    %GFSMaster.DTO.ValidationError{error: %{message: message, errors: []}}
  end

  def new(errors) when is_list(errors) do
    %GFSMaster.DTO.ValidationError{error: %{message: @default_err_msg, errors: errors}}
  end

  @spec new(binary, list()) :: GFSMaster.DTO.ValidationError.t()
  def new(message, errors) when is_binary(message) and is_list(errors) do
    %GFSMaster.DTO.ValidationError{error: %{message: message, errors: errors}}
  end
end
