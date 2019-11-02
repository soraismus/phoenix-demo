defmodule AssessmentWeb.SessionController do
  use AssessmentWeb, :controller

  alias Assessment.Accounts
  alias Assessment.Accounts.Agent

  def new(conn, _params) do
    changeset = Accounts.change_agent()
    render(conn, "new.html", changeset: changeset, errors?: false)
  end

  def create(conn, %{"agent" => %{"username" => username}}) do
    case Accounts.get_agent_by_username(username) do
      {:ok, agent} ->
        conn
        |> put_flash(:info, "Welcome back!")
        |> put_session(:agent_id, agent.id)
        |> configure_session(renew: true)
        |> redirect(to: "/")
      {:error, :no_resource} ->
        changeset =
          Agent.changeset(%Agent{}, %{username: username})
          |> Ecto.Changeset.add_error(:username, "Invalid username")
        changeset = %{changeset | action: :show_errors}
        conn
        |> render("new.html", changeset: changeset, errors?: true)
        #conn
        #|> put_flash(:error, "Invalid username")
        #|> redirect(to: session_path(conn, :new))
    end
  end

  def delete(conn, _) do
    conn
    |> put_flash(:info, "Logged out")
    |> configure_session(drop: true)
    |> redirect(to: "/")
  end
end
