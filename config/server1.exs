use Mix.Config

port = 8881

config :msf, :uri, "127.0.0.1:#{port}"

config :maru, MSF.API, http: [port: port]