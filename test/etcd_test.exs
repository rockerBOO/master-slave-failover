defmodule MsfEtcd.Test do
  use ExUnit.Case
  alias MSF.Etcd

  setup_all do
    :ok = :hackney.start

    on_exit fn ->
      # Etcd.delete("/test")
      Etcd.delete_dir("/test", :recursive)
    end

    :ok
  end



  # test "cas_if_empty ttl" do

  #   # Etcd.delete("/test")
  #   Etcd.delete_dir("/test", :recursive)

  #   # Etcd.cas_if_empty("/test", "test")

  #   # Etcd.cas_if_empty("/test", "test", 2)


  #   # Etcd.set("/test", "test", 2)

  #   Etcd.get("/test")

  #   :timer.sleep(3000)

  #   assert "" == Etcd.get("/test") |> output_value()
  # end


  test "set ttl" do

    # Etcd.delete("/test")
    Etcd.delete_dir("/test", :recursive)

    # Etcd.set("/test?prevExists=false", "test")

    # Etcd.set("/test?prevValue=test", "test", 2)
    Etcd.cas_if_empty("/test", "test-new", 2)

    Etcd.get("/test")

    :timer.sleep(3000)

    assert "" == Etcd.get("/test") |> output_value()
  end

  # test "update test" do

  #   Etcd.delete("/test")

  #   Etcd.set("/test", "127.0.0.1:8881", 5)

  #   Etcd.update("/test", "127.0.0.1:8881")

  #   assert "127.0.0.1:8881" == Etcd.get("/test") |> output_value()
  # end

  def output_value(response) do
    value = Etcd.get_value(response)

    IO.inspect value

    value
  end
end
