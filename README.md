Master/Slave Auto-Failover with Etcd and a REST API
===

This is a sample project showing how auto-failover in a master/slaves system can work with [Etcd](https://github.com/coreos/etcd/), and be accessed via a REST API provided by [maru](https://github.com/falood/maru).

### Setup

Servers are setup using the Mix config. Setting the MIX_ENV to the server config `config/server1.exs`.

##### `config/server1.exs`

```elixir
port = 8881

config :msf, :uri, "127.0.0.1:#{port}"

config :maru, MSF.API, http: [port: port]
```

Modify the Etcd server location. Currently tested on 1 Etcd node.

##### `config/config.exs`

```elixir
config :etcd, :uri, "127.0.0.1:2379"
```

### Run

```
MIX_ENV=server1 iex -S mix
```

```
MIX_ENV=server2 iex -S mix
```

### Client

To test the client in iex:

```elixir
iex> MSF.Client.get("/")
Not the master from 127.0.0.1:8882
Got hello world from 127.0.0.1:8881
```