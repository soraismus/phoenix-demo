defmodule AssessmentWeb.CourierController do
  use AssessmentWeb, :controller

  alias Assessment.Accounts
  alias Assessment.Accounts.Agent

  @ok :ok
  @error :error

  def index(conn, _params) do
    couriers = Accounts.list_couriers()
    render(conn, "index.html", couriers: couriers)
  end

  def new(conn, _params) do
    changeset = Accounts.change_courier()
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"agent" => agent_params}) do
    case Accounts.create_courier(agent_params) do
      {@ok, %Agent{courier: courier}} ->
        conn
        |> put_flash(:info, "Courier created successfully.")
        |> redirect(to: courier_path(conn, :show, courier))
      {@error, %Ecto.Changeset{} = changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    with {@ok, courier} = Accounts.get_courier(id) do
      render(conn, "show.html", courier: courier)
    end
  end

  def delete(conn, %{"id" => id}) do
    with {@ok, courier} = Accounts.get_courier(id),
         {@ok, _} = Accounts.delete_courier(courier) do
      conn
      |> put_flash(:info, "Administrator deleted successfully.")
      |> redirect(to: courier_path(conn, :index))
    end
  end
end
