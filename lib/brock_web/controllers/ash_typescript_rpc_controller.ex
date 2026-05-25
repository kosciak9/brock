defmodule BrockWeb.AshTypescriptRpcController do
  use BrockWeb, :controller

  def run(conn, params) do
    result = AshTypescript.Rpc.run_action(:brock, conn, params)
    json(conn, result)
  end

  def validate(conn, params) do
    result = AshTypescript.Rpc.validate_action(:brock, conn, params)
    json(conn, result)
  end
end
