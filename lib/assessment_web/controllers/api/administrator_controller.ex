defmodule AssessmentWeb.Api.AdministratorController do
  use AssessmentWeb, :controller
  alias Assessment.Accounts
  alias Assessment.Accounts.Agent

  def create(conn, %{"administrator" => %{"username" => u, "password" => p, "email" => e}}) do
    agent_params =
      %{}
      |> Map.put("username", u)
      |> Map.put("credential", %{"password" => p})
      |> Map.put("administrator", %{"email" => e})
    case Accounts.create_administrator(agent_params) do
      {:ok, %Agent{administrator: administrator}} ->
        conn
        |> render("create.json", administrator: administrator)
      {:error, %Ecto.Changeset{} = changeset} ->
        conn
        |> json("Error")
    end
  end

  def index(conn, _params) do
    administrators = Accounts.list_administrators()
    conn
    |> render("index.json", administrators: administrators)
  end

  def show(conn, %{"id" => id}) do
    with {:ok, administrator} <- Accounts.get_administrator(id) do
      conn
      |> render("show.json", administrator: administrator)
    end
  end
end
