defmodule GFSMaster.Router do
  use Plug.Router
  use Witchcraft.Functor
  use Witchcraft.Chain
  use Witchcraft.Arrow
  require Logger
  require Protocol
  import Plug.Conn
  alias Algae.Either
  use Plug.ErrorHandler
  use Witchcraft.Chain

  Protocol.derive(Jason.Encoder, ExJsonSchema.Validator.Error)
  Protocol.derive(Jason.Encoder, ExJsonSchema.Validator.Error.Required)
  Protocol.derive(Jason.Encoder, ExJsonSchema.Validator.Error.Type)

  def init(options) do
    options
  end

  plug(Plug.Logger)

  plug(:match)

  plug(Plug.Parsers,
    parsers: [:json],
    pass: ["application/json"],
    json_decoder: Jason
  )

  plug(:dispatch, builder_opts())

  post "/files" do
    put_resp_content_type = &put_resp_content_type(&1, "application/json")

    pipeline = fn x ->
      x.body_params
      |> GFSMaster.DTO.CreateFile.validate() >>>
        fn dto -> GFSMaster.Database.FileMetadata.create_file(dto.file_name, dto.is_dir) end
      |> (fn result ->
            case result do
              %Either.Right{} ->
                {201}

              %Either.Left{left: {:error_validation, errors}} ->
                {400,
                 %{"error" => %{"message" => "schema validation error", errors: errors}}
                 |> Jason.encode!()}

              %Either.Left{left: {:file_already_exists, file_path}} ->
                {400,
                 %{"error" => %{"message" => "file already exists", "file_path" => file_path}}
                 |> Jason.encode!()}

              %Either.Left{left: {:parents_are_not_directories, invalid_directories}} ->
                {400,
                 %{
                   "error" => %{
                     "message" => "the parents of this file must all be directories",
                     "invalid_directories" => invalid_directories
                   }
                 }
                 |> Jason.encode!()}

              %Either.Left{left: {:missing_parents_dirs, missing_directories}} ->
                {400,
                 %{
                   "error" => %{
                     "message" => "file is missing parent directories",
                     "missing_directories" => missing_directories
                   }
                 }
                 |> Jason.encode!()}

              _ ->
                {:error, result.left}
            end
          end).()
    end

    (put_resp_content_type &&& pipeline).(conn)
    |> (fn {conn, result} ->
          case result do
            {:error, err} ->
              IO.inspect(err)
              send_resp(conn, 500, GFSMaster.DTO.InternalServerError.new() |> Jason.encode!())

            {status} ->
              send_resp(conn, status, "")

            {status, resp} ->
              send_resp(conn, status, resp)
          end
        end).()
  end

  match _ do
    send_resp(conn, 404, "")
  end
end
