defmodule MsfNode.Test do
  use ExUnit.Case
  alias MSF.Node

  test "node list to string" do
    node_list = Node.node_list_to_string(Enum.into(["127.0.0.1:8881", "127.0.0.1:8882"], HashSet.new))
  end

  test "add node to node list" do
    Node.add_node_to_node_list("127.0.0.1:8881", [])
    |> IO.inspect

    Node.add_node_to_node_list("127.0.0.1:8882", Enum.into(["127.0.0.1:8881"], HashSet.new))
    |> IO.inspect

    Node.add_node_to_node_list("127.0.0.1:8882", Enum.into(["127.0.0.1:8881", "127.0.0.1:8882"], HashSet.new))
    |> IO.inspect
  end
end
