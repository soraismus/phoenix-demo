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

  import Phoenix.ConnTest, only: [build_conn: 0, post: 3]
  import AssessmentWeb.Router.Helpers, only: [session_path: 2]

  using do
    quote do
      # Import conveniences for testing with connections
      use Phoenix.ConnTest
      import AssessmentWeb.Router.Helpers

      # The default endpoint for testing
      @endpoint AssessmentWeb.Endpoint
    end
  end

  setup tags do
    :ok = Ecto.Adapters.SQL.Sandbox.checkout(Assessment.Repo)
    unless tags[:async] do
      Ecto.Adapters.SQL.Sandbox.mode(Assessment.Repo, {:shared, self()})
    end
    {:ok, conn: build_conn()}
  end

  def log_in_admin(_) do
    username = "admin_username"
    password = "admin_password"
    {:ok, _admin} =
      Assessment.Accounts.create_administrator(%{
        username: username,
        administrator: %{
          email: "admin@example.com",
        },
        credential: %{
          password: password,
        }
      })
    credential = %{username: username, password: password}
    {:ok, conn: get_authenticated_connection(credential)}
  end

  defp get_authenticated_connection(credential) do
    conn0 = build_conn()
    response = post(conn0, session_path(conn0, :create), credential)
    token = Poison.Parser.parse!(response.resp_body)["token"]
    Plug.Conn.put_req_header(build_conn(), "authorization", "token: #{token}")
  end
end
