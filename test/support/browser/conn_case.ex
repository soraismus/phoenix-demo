defmodule AssessmentWeb.Browser.ConnCase do
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
    {:ok, conn: Phoenix.ConnTest.build_conn()}
  end

  def log_in_admin(_) do
    {:ok, admin} =
      Assessment.Accounts.create_administrator(%{
        username: "admin",
        administrator: %{
          email: "admin@example.com"
        },
        credential: %{
          password: "admin"
        }
      })
    subject = %{agent_id: admin.id}
    conn =
      Phoenix.ConnTest.build_conn()
      |> AssessmentWeb.Guardian.Plug.sign_in(subject)
    {:ok, conn: conn}
  end
end
