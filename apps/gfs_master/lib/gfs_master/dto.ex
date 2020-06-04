require Protocol

alias Algae.Either

defmodule GFSMaster.DTO.CreateFile do
  @type t :: %__MODULE__{}

  @file_name "file_name"
  @is_dir "is_dir"

  defstruct file_name: "", is_dir: ""

  @spec validate(any) :: %{
          :__struct__ => Algae.Either.Left | Algae.Either.Right,
          optional(:left) => ExJsonSchema.Validator.Error,
          optional(:right) => GFSMaster.DTO.CreateFile
        }
  def validate(body) do
    %{
      "type" => "object",
      "required" => [@file_name, @is_dir],
      "properties" => %{
        @file_name => %{
          "type" => "string"
        },
        @is_dir => %{
          "type" => "boolean"
        }
      }
    }
    |> ExJsonSchema.Schema.resolve()
    |> ExJsonSchema.Validator.validate(body, error_formatter: false)
    |> (fn result ->
          case result do
            :ok ->
              %GFSMaster.DTO.CreateFile{
                file_name: body[@file_name],
                is_dir: body[@is_dir]
              }
              |> Either.Right.new()

            {:error, reason} ->
              {:error_validation, reason} |> Either.Left.new()
          end
        end).()
  end
end

defmodule GFSMaster.DTO.InternalServerError do
  @type t :: %__MODULE__{}

  @derive Jason.Encoder
  defstruct message: "Internal Server Error"

  @spec new :: GFSMaster.DTO.InternalServerErrorDTO.t()
  def new() do
    %GFSMaster.DTO.InternalServerError{}
  end

  @spec new(String.t()) :: GFSMaster.InternalServerErrorDTO.t()
  def new(message) do
    %GFSMaster.DTO.InternalServerError{message: message}
  end
end
