defmodule MSF.Node do
  require Logger
  alias MSF.Etcd

  @node_ttl 5

  def set_node(node) do
    Etcd.set("/nodes/#{node}", node, @node_ttl)
  end

  def nodes() do
    case Etcd.get("/nodes") |> Etcd.handle_response() do
      {:ok, nil}    -> []
      {:ok, value}  -> value
      {:error, {code, message}}
                    -> []
      _             -> []
    end
  end

  def node_list_to_string(list) do
    Enum.join(list, ",")
  end

  def to_set(nodes) when is_binary(nodes) do
    Enum.reduce(nodes, HashSet.new, fn (node, acc) ->
      Set.put(acc, node)
    end)
  end

  def add_node_to_node_list(node, []) do
    Set.put(HashSet.new, node)
  end

  def add_node_to_node_list(node, nodes) do
    Set.put(nodes, node)
  end

  def add_node_to_node_list(node, nodes) do
    Enum.reduce(nodes, HashSet.new, fn (node, acc) ->
      Set.put(acc, node)
    end)
  end
end