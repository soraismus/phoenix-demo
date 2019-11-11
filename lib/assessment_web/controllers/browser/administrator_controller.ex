defmodule AssessmentWeb.Browser.AdministratorController do
  use AssessmentWeb, :controller

  import AssessmentWeb.Browser.ControllerUtilities,
    only: [ internal_error: 2,
            resource_error: 3,
          ]

  alias Assessment.Accounts
  alias Assessment.Accounts.Agent

  plug :authenticate_administrator

  @error :error
  @ignore :ignore
  @index :index
  @info :info
  @new :new
  @no_resource :no_resource
  @ok :ok
  @request_path :request_path
  @show :show

  def index(conn, _params) do
    conn
    |> render("index.html", administrators: Accounts.list_administrators())
  end

  def new(conn, _params) do
    conn
    |> render("new.html", changeset: Accounts.change_administrator())
  end

  def create(conn, %{"agent" => agent_params}) do
    case Accounts.create_administrator(agent_params) do
      {@ok, %Agent{administrator: administrator}} ->
        conn
        |> put_flash(@info, "Administrator created successfully.")
        |> redirect(to: administrator_path(conn, @show, administrator))
      {@error, %Ecto.Changeset{} = changeset} ->
        conn
        |> render("new.html", changeset: changeset)
      _ ->
        conn
        |> internal_error("ADCR_B")
    end
  end

  def show(conn, %{"id" => id}) do
    with {@ok, administrator} <- Accounts.get_administrator(id) do
      conn
      |> render("show.html", administrator: administrator)
    else
      {@error, @no_resource} ->
        conn
        |> resource_error("administrator ##{id}", "does not exist")
      _ ->
        conn
        |> internal_error("ADSH_B")
    end
  end

  def delete(conn, %{"id" => id}) do
    with {@ok, administrator} <- Accounts.get_administrator(id),
         {@ok, _} = Accounts.delete_administrator(administrator) do
      conn
      |> put_flash(@info, "Administrator deleted successfully.")
      |> redirect(to: administrator_path(conn, @index))
    else
      {@error, @no_resource} ->
        conn
        |> resource_error("administrator ##{id}", "does not exist")
      _ ->
        conn
        |> internal_error("ADDE_B")
    end
  end

  defp authenticate_administrator(conn, _) do
    agent = conn.assigns.agent
    if agent && agent.account_type == "administrator" do
      conn
    else
      conn
      |> put_flash(@error, "You must be logged in as an administrator to manage administrators.")
      |> put_session(@request_path, @ignore)
      |> redirect(to: session_path(conn, @new))
      |> halt()
    end
  end
end
