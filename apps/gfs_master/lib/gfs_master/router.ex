alias Algae.Either
alias GFSMaster.ResultHandlers
alias GFSMaster.DTO
alias GFSMaster.Database

defmodule GFSMaster.Router do
  require Logger
  require Protocol

  use Plug.Router
  use Witchcraft.Functor
  use Witchcraft.Chain
  use Witchcraft.Arrow
  use Plug.ErrorHandler
  use Witchcraft.Chain

  import Plug.Conn

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
      |> DTO.CreateFile.validate() >>>
        fn dto -> Database.FileMetadata.create_file(dto.file_name, dto.is_dir) end
      |> ResultHandlers.pipe([
        ResultHandlers.handle_success(201),
        ResultHandlers.handle_validation_error(),
        ResultHandlers.handle_file_already_exists_error(),
        ResultHandlers.handle_parents_are_not_directories(),
        ResultHandlers.handle_missing_directories()
      ]).()
    end

    (put_resp_content_type &&& pipeline).(conn)
    |> (fn {conn, result} ->
          case result do
            %Either.Left{left: err} ->
              IO.inspect(err)
              send_resp(conn, 500, DTO.InternalServerError.new() |> Jason.encode!())

            {status} ->
              send_resp(conn, status, "")

            {status, resp} ->
              send_resp(conn, status, resp |> Jason.encode!())
          end
        end).()
  end

  match _ do
    send_resp(conn, 404, "404 Not Found")
  end
end
