defmodule GFSMaster.CreateFileDTO do
  @spec validate(false | nil | true | binary | [any] | number | %{optional(binary) => any}) ::
          :ok | {:error, [any]}
  def validate(body) do
    %{
      "type" => "object",
      "required" => ["fileName"],
      "properties" => %{
        "fileName" => %{
          "type" => "string"
        }
      }
    }
    |> ExJsonSchema.Schema.resolve()
    |> ExJsonSchema.Validator.validate(body, error_formatter: false)
  end
end
