defmodule AssessmentWeb.Api.CourierController do
  use AssessmentWeb, :controller

  import AssessmentWeb.Api.ControllerUtilities,
    only: [ authentication_error: 1,
            authorization_error: 1,
            changeset_error: 2,
            internal_error: 2,
            resource_error: 4
          ]
  import AssessmentWeb.GuardianController, only: [authenticate_administrator: 1]

  alias Assessment.Accounts

  def create(conn, %{"courier" => params}) do
    params =
      %{}
      |> Map.put("username", Map.get(params, "username"))
      |> Map.put("credential", Map.take(params, ["password"]))
      |> Map.put("courier", Map.take(params, ["name", "email", "address"]))
    with {:ok, _} <- authenticate_administrator(conn),
         {:ok, agent} <- Accounts.create_courier(params) do
      conn
      |> put_status(:created)
      |> render("create.json", courier: agent.courier)
    else
      {:error, :not_authenticated} ->
        conn
        |> authentication_error()
      {:error, :not_authorized} ->
        conn
        |> authorization_error()
      {:error, %Ecto.Changeset{} = changeset} ->
        conn
        |> changeset_error(changeset)
      _ ->
        conn
        |> internal_error("COCR")
    end
  end

  def index(conn, _params) do
    case authenticate_administrator(conn) do
      {:ok, _} ->
        conn
        |> render("index.json", couriers: Accounts.list_couriers())
      {:error, :not_authenticated} ->
        conn
        |> authentication_error()
      {:error, :not_authorized} ->
        conn
        |> authorization_error()
      _ ->
        conn
        |> internal_error("COIN")
      end
  end

  def show(conn, %{"id" => id}) do
    with {:ok, _} <- authenticate_administrator(conn),
         {:ok, courier} <- Accounts.get_courier(id) do
      conn
      |> render("show.json", courier: courier)
    else
      {:error, :not_authenticated} ->
        conn
        |> authentication_error()
      {:error, :not_authorized} ->
        conn
        |> authorization_error()
      {:error, :no_resource} ->
        conn
        |> resource_error("courier ##{id}", "does not exist", :not_found)
      _ ->
        conn
        |> internal_error("COSH")
    end
  end
end
