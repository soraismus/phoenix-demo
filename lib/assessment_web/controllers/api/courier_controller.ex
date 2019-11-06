defmodule AssessmentWeb.Api.CourierController do
  use AssessmentWeb, :controller
  import AssessmentWeb.Api.ControllerUtilities,
    only: [changeset_error: 3, internal_error: 1, resource_error: 3]
  alias Assessment.Accounts

  def create(conn, %{"courier" => params}) do
    params =
      %{}
      |> Map.put("username", Map.get(params, "username"))
      |> Map.put("credential", Map.take(params, ["password"]))
      |> Map.put("courier", Map.take(params, ["name", "email", "address"]))
    case Accounts.create_courier(params) do
      {:ok, agent} ->
        conn
        |> put_status(:created)
        |> render("create.json", courier: agent.courier)
      {:error, %Ecto.Changeset{} = changeset} ->
        conn
        |> changeset_error(changeset)
      _ ->
        conn
        |> internal_error("COCR")
    end
  end

  def index(conn, _params) do
    conn
    |> render("index.json", couriers: Accounts.list_couriers())
  end

  def show(conn, %{"id" => id}) do
    case Accounts.get_courier(id) do
      {:ok, courier} ->
        conn
        |> render("show.json", courier: courier)
      {:error, :no_resource} ->
        conn
        |> resource_error("courier ##{id}", "does not exist", :not_found)
      _ ->
        conn
        |> internal_error("COSH")
    end
  end
end
