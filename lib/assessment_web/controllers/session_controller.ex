defmodule AssessmentWeb.SessionController do
  use AssessmentWeb, :controller

  alias Assessment.Accounts
  alias Assessment.Accounts.{Agent,Credential}
  alias Ecto.Changeset

  @ok :ok
  @error :error
  @unauthenticated :unauthenticated

  def new(conn, _params) do
    conn
    |> assign(:changeset, Accounts.change_agent())
    |> render("new.html")
  end

  def create(conn, %{"agent" => %{"username" => username, "credential" => %{"password" => password}} = agent_params}) do
    changeset =
      %Agent{}
      |> Agent.changeset(agent_params)
      |> Changeset.cast_assoc(:credential, with: &Credential.validate/2)
    if changeset.valid? do
      case Accounts.get_agent_by_username_and_password(username, password) do
        {@ok, agent} ->
          conn
          |> configure_session(renew: true)
          |> put_flash(:info, "Welcome back!")
          |> put_session(:agent_id, agent.id)
          |> redirect(to: page_path(conn, :index))
        {@error, @unauthenticated} ->
          conn
          |> clear_session()
          |> put_flash(@error, "Invalid username/password combination")
          |> redirect(to: session_path(conn, :new))
      end
    else
      conn
      |> assign(:changeset, %{changeset | action: :show_errors})
      |> render("new.html")
    end
  end

  def delete(conn, _) do
    conn
    |> configure_session(drop: true)
    |> redirect(to: page_path(conn, :index))
  end
end
