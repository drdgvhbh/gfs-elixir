defmodule GFSMaster.DTO.InternalServerError do
  require Protocol

  @type t :: %__MODULE__{}

  @derive Jason.Encoder
  defstruct error: %{message: ""}

  @spec new :: GFSMaster.DTO.InternalServerErrorDTO.t()
  def new() do
    %GFSMaster.DTO.InternalServerError{}
  end

  @spec new(String.t()) :: GFSMaster.InternalServerErrorDTO.t()
  def new(message) do
    %GFSMaster.DTO.InternalServerError{error: {message}}
  end
end
