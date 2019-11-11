defmodule AssessmentWeb.CourierController do
  use AssessmentWeb, :controller

  import AssessmentWeb.ControllerUtilities,
    only: [ internal_error: 2,
            resource_error: 3,
          ]

  alias Assessment.Accounts
  alias Assessment.Accounts.Agent

  plug :authenticate_administrator

  def index(conn, _params) do
    conn
    |> render("index.html", couriers: Accounts.list_couriers())
  end

  def new(conn, _params) do
    conn
    |> render("new.html", changeset: Accounts.change_courier())
  end

  def create(conn, %{"agent" => agent_params}) do
    case Accounts.create_courier(agent_params) do
      {:ok, %Agent{courier: courier}} ->
        conn
        |> put_flash(:info, "Courier created successfully.")
        |> redirect(to: courier_path(conn, :show, courier))
      {:error, %Ecto.Changeset{} = changeset} ->
        conn
        |> render("new.html", changeset: changeset)
      _ ->
        conn
        |> internal_error("COCR_B")
    end
  end

  def show(conn, %{"id" => id}) do
    with {:ok, courier} = Accounts.get_courier(id) do
      conn
      |> render("show.html", courier: courier)
    else
      {@error, @no_resource} ->
        conn
        |> resource_error("courier ##{id}", "does not exist")
      _ ->
        conn
        |> internal_error("COSH_B")
    end
  end

  def delete(conn, %{"id" => id}) do
    with {:ok, courier} = Accounts.get_courier(id),
         {:ok, _} = Accounts.delete_courier(courier) do
      conn
      |> put_flash(:info, "Courier deleted successfully.")
      |> redirect(to: courier_path(conn, :index))
    else
      {@error, @no_resource} ->
        conn
        |> resource_error("courier ##{id}", "does not exist")
      _ ->
        conn
        |> internal_error("CODE_B")
    end
  end

  defp authenticate_administrator(conn, _) do
    agent = conn.assigns.agent
    if agent && agent.account_type == "administrator" do
      conn
    else
      conn
      |> put_flash(:error, "You must be logged in as an administrator to manage couriers.")
      |> put_session(:request_path, :ignore)
      |> redirect(to: session_path(conn, :new))
      |> halt()
    end
  end
end
