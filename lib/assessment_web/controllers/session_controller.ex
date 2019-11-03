defmodule AssessmentWeb.SessionController do
  use AssessmentWeb, :controller

  alias Assessment.Accounts
  alias Assessment.Accounts.{Agent,Credential}
  alias Ecto.Changeset

  def new(conn, _params) do
    conn
    |> assign(:changeset, Accounts.change_agent())
    |> render("new.html")
  end

  def create(conn, %{"agent" => params}) do
    changeset = session_changeset(params)
    if changeset.valid? do
      %{"username" => username, "credential" => %{"password" => password}} = params
      case Accounts.get_agent_by_username_and_password(username, password) do
        {:ok, agent} ->
          redirect_path = case get_session(conn, :request_path) do
              nil -> page_path(conn, :index)
              request_path -> request_path
            end
          conn
          |> configure_session(renew: true)
          |> put_flash(:info, "Welcome back!")
          |> put_session(:agent_id, agent.id)
          |> delete_session(:request_path)
          |> redirect(to: redirect_path)
        {:error, :unauthenticated} ->
          conn
          |> clear_session()
          |> put_flash(:error, "Invalid username/password combination")
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

  defp session_changeset(params) do
    %Agent{}
    |> Agent.changeset(params)
    |> Changeset.cast_assoc(:credential, with: &Credential.validate/2)
  end
end
