defmodule GFSMaster.Router do
  use Plug.Router
  require Protocol
  require Logger
  import Plug.Conn

  Protocol.derive(Jason.Encoder, ExJsonSchema.Validator.Error)
  Protocol.derive(Jason.Encoder, ExJsonSchema.Validator.Error.Type)

  def init(options) do
    Logger.info("yoloswagerino")
    file_namespace = :digraph.new()
    v1 = :digraph.add_vertex(file_namespace)
    v2 = :digraph.add_vertex(file_namespace)
    :digraph.add_edge(file_namespace, v1, v2, "derp")
    # initialize options

    {file_namespace}
  end

  plug(Plug.Logger)

  use Plug.ErrorHandler

  plug(:match)

  plug(Plug.Parsers,
    parsers: [:json],
    pass: ["application/json"],
    json_decoder: Jason
  )

  plug(:dispatch, builder_opts())

  post "/files" do
    onCreateValidate(conn, opts, conn.body_params |> GFSMaster.CreateFileDTO.validate())
  end

  match _ do
    send_resp(conn, 404, "")
  end

  defp onCreateValidate(conn, opts, :ok) do
    {file_namespace} = opts
    fileName = conn.body_params["fileName"]
    # GFS.create(fileName, file_namespace) |> IO.inspect()
    GFSMaster.Controller.create2(fileName, :file_namespace)

    conn |> send_resp(201, "Created")
  end

  defp onCreateValidate(conn, opts, error) do
    {:error, errors} = error

    conn
    |> Plug.Conn.put_resp_content_type("application/json")
    |> Plug.Conn.send_resp(400, Jason.encode!(errors))
  end
end
