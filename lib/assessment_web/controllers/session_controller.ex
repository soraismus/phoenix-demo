defmodule AssessmentWeb.SessionController do
  use AssessmentWeb, :controller

  alias Assessment.Accounts
  alias Assessment.Accounts.Agent

  @ok :ok
  @error :error

  def new(conn, _params) do
    conn
    |> assign(:changeset, Accounts.change_agent())
    |> render("new.html")
  end

  def create(conn, %{"agent" => %{"username" => username} = agent_params}) do
    changeset = Agent.changeset(%Agent{}, agent_params)
    if changeset.valid? do
      case Accounts.get_agent_by_username(username) do
        {@ok, agent} ->
          conn
          |> configure_session(renew: true)
          |> put_flash(:info, "Welcome back!")
          |> put_session(:agent_id, agent.id)
          |> redirect(to: page_path(conn, :index))
        {@error, :no_resource} ->
          conn
          |> clear_session()
          |> put_flash(@error, "Invalid username")
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
