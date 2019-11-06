defmodule AssessmentWeb.Api.AdministratorController do
  use AssessmentWeb, :controller
  import AssessmentWeb.Api.ControllerUtilities,
    only: [changeset_error: 3, internal_error: 1, resource_error: 3]
  alias Assessment.Accounts

  def create(conn, %{"administrator" => params}) do
    params =
      %{}
      |> Map.put("username", Map.get(params, "username"))
      |> Map.put("credential", Map.take(params, ["password"]))
      |> Map.put("administrator", Map.take(params, ["email"]))
    case Accounts.create_administrator(params) do
      {:ok, agent} ->
        conn
        |> put_status(:created)
        |> render("create.json", administrator: agent.administrator)
      {:error, %Ecto.Changeset{} = changeset} ->
        conn
        |> changeset_error(changeset)
      _ ->
        conn
        |> internal_error("ADCR")
    end
  end

  def index(conn, _params) do
    conn
    |> render("index.json", administrators: Accounts.list_administrators())
  end

  def show(conn, %{"id" => id}) do
    case Accounts.get_administrator(id) do
      {:ok, administrator} ->
        conn
        |> render("show.json", administrator: administrator)
      {:error, :no_resource} ->
        conn
        |> resource_error("administrator ##{id}", "does not exist", :not_found)
      _ ->
        conn
        |> internal_error("ADSH")
    end
  end
end
