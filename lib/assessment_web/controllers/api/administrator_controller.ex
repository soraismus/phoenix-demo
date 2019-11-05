defmodule AssessmentWeb.Api.AdministratorController do
  use AssessmentWeb, :controller
  alias Assessment.Accounts
  alias Assessment.Accounts.Agent

  action_fallback(AssessmentWeb.Api.ErrorController)

  def create(conn, %{"administrator" => %{"username" => u, "password" => p, "email" => e}}) do
    agent_params =
      %{}
      |> Map.put("username", u)
      |> Map.put("credential", %{"password" => p})
      |> Map.put("administrator", %{"email" => e})
    with {:ok, agent} <- Accounts.create_administrator(agent_params) do
      render(conn, "create.json", administrator: agent.administrator)
    end
  end

  def index(conn, _params) do
    administrators = Accounts.list_administrators()
    render(conn, "index.json", administrators: administrators)
  end

  def show(conn, %{"id" => id}) do
    with {:ok, administrator} <- Accounts.get_administrator(id) do
      render(conn, "show.json", administrator: administrator)
    end
  end
end
