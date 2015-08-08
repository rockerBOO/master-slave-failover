defmodule MSF.Server do
  require Logger
  alias MSF.Etcd
  alias MSF.Node

  @refresh_at 2500
  @master_ttl 5
  @master_key "/master"

  def start_link(opts, process_opts \\ []) do
    Logger.debug "Start the server"
    GenServer.start_link(__MODULE__, opts, process_opts)
  end

  def init([]) do
    Logger.debug "Initiallizing the server"

    uri = Application.get_env(:msf, :uri)

    register(uri)
    refresh_at(@refresh_at, self)

    {:ok, [uri: uri]}
  end

  def register(uri) do
    Logger.debug "Registering node #{uri}"
    Node.set_node(uri)

    refresh_node(uri)
  end

  def is_master?() do
    Application.get_env(:msf, :uri)
    |> is_master?
  end

  def is_master?(uri) do
    case master() do
      :error -> false
      master -> master == uri
    end
  end

  def elect(uri) do
    Logger.debug "Voting for #{uri}"
    response = Etcd.cas_if_empty(@master_key, uri, @master_ttl)

    if response["errorCode"] do
      Logger.info "Could not elect to master"
      :timer.sleep(500)
      elect(uri)
    end
  end

  def master() do
    case Etcd.get(@master_key) |> Etcd.handle_response() do
      {:ok, nil}      -> :error
      {:ok, value}    -> value
      {:error, error} -> IO.inspect error; :error
    end
  end

  def refresh_master(uri) do
    Logger.debug "Refreshing master to: #{uri}"

    Etcd.update(@master_key, uri, @master_ttl)
  end

  def refresh_at(ttl, pid) do
    :erlang.send_after(ttl, pid, :ping, [])
  end

  def refresh_node(uri) do
    Logger.debug "Refreshing node: #{uri}"

    master = master()
    # IO.inspect master
    Logger.debug "Current Master: #{master}"
    Logger.debug "Current Node: #{uri}"


    Node.set_node(uri)

    # If no master, elect self
    if :error == master do
      Logger.debug "Electing to master: #{uri}"
      elect(uri)
    else
      Logger.debug "Checking if master is self: #{master} #{uri}"

      # If is master, refresh master
      if master == uri do
        refresh_master(uri)
      end
    end
  end

  def handle_info(:ping, state) do
    refresh_node(state[:uri])

    refresh_at(@refresh_at, self)

    {:noreply, state}
  end

  def terminate(_reason, state) do
    Etcd.remove_node(state.uri)

    :ok
  end
end
