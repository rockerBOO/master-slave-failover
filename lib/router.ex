defmodule MSF.API do
  use Maru.Router

  get do
    if MSF.Server.is_master? do
      status 200
      # Sleep some to simulate load
      :timer.sleep(300)

      "Hello World!"
    else
      status 503

      "I'm ready for work boss, if this master would just die already..."
    end
  end

  rescue_from :all do
    status 500
    "Server Error"
  end
end