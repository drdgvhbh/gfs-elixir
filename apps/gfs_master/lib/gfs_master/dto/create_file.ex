alias Algae.Either

defmodule GFSMaster.DTO.CreateFile.JSONValidationSchema do
  require Protocol

  @type t :: %__MODULE__{}

  @file_name "file_name"
  @is_dir "is_dir"

  defstruct schema: %{
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

  @spec new :: GFSMaster.DTO.CreateFile.JSONValidationSchema.t()
  def new do
    %GFSMaster.DTO.CreateFile.JSONValidationSchema{}
  end
end

defmodule GFSMaster.DTO.CreateFile do
  @type t :: %__MODULE__{}

  @file_name "file_name"
  @is_dir "is_dir"

  defstruct [:file_name, :is_dir]

  @spec validate(any) :: %{
          :__struct__ => Either.Left | Either.Right,
          optional(:left) => ExJsonSchema.Validator.Error,
          optional(:right) => GFSMaster.DTO.CreateFile
        }
  def validate(body) do
    GFSMaster.DTO.CreateFile.JSONValidationSchema.new().schema
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
