defmodule MSF.Etcd do
  use HTTPoison.Base
  require Logger

  alias MSF.Etcd.Request

  defmodule Error do
    defexception code: 0, message: ""
  end

  def start_link(opts, process_opts \\ []) do
    GenServer.start_link(__MODULE__, opts, process_opts)
  end

  def init([]) do
    uri = Application.get_env(:etcd, :uri)

    {:ok, [uri: uri]}
  end

  def get(key) do
    Logger.debug "GET #{key}"

    Request.get!(key)
    |> parse_response
  end

  def set_dir(key) do
    Logger.debug "PUT set_dir/1 #{key}" <> " -d dir=true"

    Request.put!(key, "dir=true")
    |> parse_response
  end

  def update(key, value) do
    Logger.debug "PUT update/2 #{key}" <> " -d value=#{value}&ttl=&prevExists=true"

    Request.put!(key, "value=#{value}&ttl=&prevExists=true")
    |> parse_response
  end

  def update(key, value, ttl) do
    Logger.debug "PUT update/3 #{key}" <> " -d value=#{value}&ttl=#{ttl}&prevExists=true"

    Request.put!(key, "value=#{value}&ttl=#{ttl}&prevExists=true")
    |> parse_response
  end

  def set(key, value) do
    Logger.debug "PUT set/2 #{key}" <> " -d value=#{value}"

    Request.put!(key, "value=#{value}")
    |> parse_response
  end

  def set(key, value, ttl) do
    Logger.debug "PUT set/3 #{key}" <> " -d value=#{URI.encode(value)}&ttl=#{ttl}"

    Request.put!(key, "value=#{URI.encode(value)}&ttl=#{ttl}")
    |> parse_response
  end

  def cas(key, prevValue, value, ttl) do
    set("#{key}?prevValue=#{prevValue}", value, ttl)
  end

  def cas(key, prevValue, value) do
    set("#{key}?prevValue=#{prevValue}", value)
  end

  def cas_if_empty(key, value, ttl) do
    set("#{key}?prevExists=false", value, ttl)
  end

  def cas_if_empty(key, value) do
    set("#{key}?prevExists=false", value)
  end

  def delete(key) do
    Logger.debug "DELETE delete/1 #{key}"

    Request.delete!(key)
    |> parse_response
  end

  def delete_dir(key, opts \\ []) do
    if Keyword.keyword?(:recursive) do
      request_opts = "&recursive=true"
    else
      request_opts = ""
    end

    Request.delete!("#{key}?dir=true#{request_opts}")
    |> parse_response
  end

  def find_error(response) do
    case response["errorCode"] do
      100 -> {:error, {response["errorCode"], response["message"]}}
      _   -> {:ok, :ok}
    end
  end

  def get_value(response) do
    case handle_response(response) do
      {:ok, value} -> value
      {:error, _}  -> ""
    end
  end

  def handle_response(response) do
    # IO.inspect response

    case find_error(response) do
      {:ok, _}        -> {:ok, parse_value(response["node"])}
      {:error, error} -> {:error, error}
    end
  end

  def parse_response(response) do
    # IO.inspect Map.fetch!(response, :body)

    if Map.has_key?(response, :body) do
      response |> Map.fetch!(:body)
    end
  end

  def parse_value(node) do
    if Map.has_key?(node, "nodes") do
      # Logger.debug "Parsing nodes..."
      parse_values(node["nodes"])
    else
      node["value"]
    end
  end

  def parse_values(nodes) do
    get_value_from_node(HashSet.new, nodes)
  end

  def get_value_from_node(set, [node]) do
    Set.put(set, node["value"])
  end

  def get_value_from_node(set, [node|tail]) do
    Set.put(set, node["value"])
    |> get_value_from_node(tail)
  end

  def get_value_from_node(set, []), do: nil

  def terminate(reason, state) do
    IO.inspect reason
    :ok
  end
end
