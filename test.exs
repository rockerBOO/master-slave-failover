nodes = [%{"value" => "x"}]

Enum.each(nodes, fn (node) ->
  IO.puts "Each"
  IO.inspect node["value"]
end)

Enum.reduce(nodes, fn (node, acc) ->
  IO.puts "Reduce"
  IO.inspect node["value"]

  [node["value"], acc]
end)

Enum.reduce(nodes, [], fn (node, acc) ->
  IO.puts "Pre-accumulator"
  IO.inspect node["value"]

  [node["value"], acc]
end)