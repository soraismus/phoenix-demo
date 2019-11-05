defmodule AssessmentWeb.Api.AdministratorController do
  use AssessmentWeb, :controller
  import Assessment.Utilities, only: [error_data: 1]
  alias Assessment.Accounts

  action_fallback(AssessmentWeb.Api.ErrorController)

  def create(conn, %{"administrator" => params}) do
    params =
      %{}
      |> Map.put("username", Map.get(params, "username"))
      |> Map.put("credential", Map.take(params, ["password"]))
      |> Map.put("administrator", Map.take(params, ["email"]))
    with {:ok, agent} <- Accounts.create_administrator(params) do
      conn
      |> put_status(:created)
      |> render("create.json", administrator: agent.administrator)
    end
  end

  def index(conn, _params) do
    conn
    |> render("index.json", administrators: Accounts.list_administrators())
  end

  def show(conn, %{"id" => id}) do
    data = %{resource: "administrator ##{id}"}
    with {:ok, administrator} <- Accounts.get_administrator(id) |> error_data(data).() do
      conn
      |> render("show.json", administrator: administrator)
    end
  end
end
