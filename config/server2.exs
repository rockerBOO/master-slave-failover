
use Mix.Config

port = 8882

config :msf, :uri, "127.0.0.1:#{port}"

config :maru, MSF.API, http: [port: port]