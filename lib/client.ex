defmodule MSF.Client do
  require Logger
  alias MSF.Node
  alias MSF.Request

  def get(method) do
    Enum.each(Node.nodes(), fn node ->
      spawn(fn ->
        response = Request.get!("http://#{node}/#{method}")

        if response.body == "Hello World!" do
          IO.puts "Got hello world from #{node}"
        else
          IO.puts "Not the master from #{node}"
        end
      end)
    end)
  end
end
