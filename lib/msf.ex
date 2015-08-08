defmodule MSF do

  def start(_type, _args) do
    import Supervisor.Spec, warn: false

    children = [
      worker(MSF.Etcd, [[], [name: :etcd]]),
      worker(MSF.Server, [[], [name: :server_node]])
    ]

    opts = [strategy: :one_for_one, name: __MODULE__]
    {:ok, _} = Supervisor.start_link(children, opts)
  end
end
