defmodule MSF.Etcd.Request do
  use HTTPoison.Base

  def process_url(url) do
    "http://#{Application.get_env(:etcd, uri)}/v2/keys" <> url
  end

  def process_request_headers(headers) do
    [{"Content-Type", "application/x-www-form-urlencoded"} | headers]
  end

  def process_response_body(body) do
    body |> Poison.decode!()
  end
end
