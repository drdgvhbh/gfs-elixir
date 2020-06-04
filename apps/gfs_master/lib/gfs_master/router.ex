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
      |> GFSMaster.ResultHandlers.pipe([
        GFSMaster.ResultHandlers.handle_success(201),
        GFSMaster.ResultHandlers.handle_validation_error(),
        GFSMaster.ResultHandlers.handle_file_already_exists_error(),
        GFSMaster.ResultHandlers.handle_parents_are_not_directories(),
        GFSMaster.ResultHandlers.handle_missing_directories()
      ]).()
    end

    (put_resp_content_type &&& pipeline).(conn)
    |> (fn {conn, result} ->
          case result do
            %Either.Left{left: err} ->
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
