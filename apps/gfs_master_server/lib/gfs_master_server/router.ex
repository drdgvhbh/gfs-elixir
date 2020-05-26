defmodule Router do
  use Plug.Router
  require Logger
  import Plug.Conn

  def init(options) do
    Logger.info("yoloswagerino")
    file_namespace = :digraph.new()
    v1 = :digraph.add_vertex(file_namespace)
    v2 = :digraph.add_vertex(file_namespace)
    :digraph.add_edge(file_namespace, v1, v2, "aaaa")
    # initialize options
    options |> IO.inspect()

    {:ok, {file_namespace}}
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

  post "/" do
    IO.inspect(conn.body_params)

    schema =
      %{
        "type" => "object",
        "properties" => %{
          "id" => %{
            "type" => ["integer", "string", "null"]
          },
          "method" => %{
            "type" => "string"
          },
          "jsonrpc" => %{
            "enum" => ["2.0"]
          }
        }
      }
      |> ExJsonSchema.Schema.resolve()

    id = conn.body_params["id"]
    method = conn.body_params["method"]
    params = conn.body_params["params"]

    {:ok, {file_namespace}} = opts

    :ok = ExJsonSchema.Validator.validate(schema, conn.body_params)

    response_obj =
      case method do
        "join-cluster" ->
          resp(conn, 200, "yolo")

        "create" ->
          :ok = GFS.create(Enum.at(params, 0), file_namespace)
          resp(conn, 200, "swag")

        _ ->
          resp(conn, 200, "swag")
      end

    Plug.Conn.send_resp(response_obj)
  end

  match _ do
    send_resp(conn, 404, "")
  end

  defp handle_errors(conn, %{kind: _kind, reason: _reason, stack: _stack}) do
    send_resp(conn, conn.status, "Something went wrong")
  end
end
