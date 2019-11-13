defmodule AssessmentWeb.Api.ConnCase do
  @moduledoc """
  This module defines the test case to be used by
  tests that require setting up a connection.

  Such tests rely on `Phoenix.ConnTest` and also
  import other functionality to make it easier
  to build common datastructures and query the data layer.

  Finally, if the test case interacts with the database,
  it cannot be async. For this reason, every test runs
  inside a transaction which is reset at the beginning
  of the test unless the test case is marked as async.
  """

  use ExUnit.CaseTemplate

  import Assessment.DataCase, only: [fixture: 1, get_password: 1]
  import AssessmentWeb.Router.Helpers, only: [api_session_path: 2]
  import Phoenix.ConnTest, only: [build_conn: 0, post: 3]
  import Plug.Conn, only: [put_req_header: 3]

  using do
    quote do
      # Import conveniences for testing with connections
      use Phoenix.ConnTest
      import AssessmentWeb.Router.Helpers

      # The default endpoint for testing
      @endpoint AssessmentWeb.Endpoint
    end
  end

  @endpoint AssessmentWeb.Endpoint

  setup tags do
    :ok = Ecto.Adapters.SQL.Sandbox.checkout(Assessment.Repo)
    unless tags[:async] do
      Ecto.Adapters.SQL.Sandbox.mode(Assessment.Repo, {:shared, self()})
    end
    {:ok, conn: build_conn()}
  end

  def add_administrator(context) do
    administrators = Map.get(context, :administrators) || []
    administrator = fixture(:administrator)
    {:ok, administrators: [administrator | administrators]}
  end

  def add_courier(context) do
    couriers = Map.get(context, :couriers) || []
    courier = fixture(:courier)
    {:ok, couriers: [courier | couriers]}
  end

  def add_pharmacy(context) do
    pharmacies = Map.get(context, :pharmacies) || []
    pharmacy = fixture(:pharmacy)
    {:ok, pharmacies: [pharmacy | pharmacies]}
  end

  def log_in_admin(%{administrators: [administrator | _]}) do
    credential = %{ "username" => administrator.username,
                    "password" => get_password(administrator),
                  }
    {:ok, conn: get_authenticated_connection(credential)}
  end

  defp get_authenticated_connection(credential) do
    conn0 = build_conn()
    response =
      conn0
      |> put_req_header("content-type", "application/json")
      |> put_req_header("accept", "application/json")
      |> post(api_session_path(conn0, :create), credential)
    token = Poison.Parser.parse!(response.resp_body)["session"]["token"]
    put_req_header(build_conn(), "authorization", "token: #{token}")
  end
end
