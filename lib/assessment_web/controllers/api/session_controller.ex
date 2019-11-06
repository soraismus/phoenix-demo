defmodule AssessmentWeb.Api.SessionController do
  use AssessmentWeb, :controller
  import Assessment.Utilities, only: [error_data: 1]
  alias Assessment.Accounts
  alias Assessment.Orders
  alias AssessmentWeb.Guardian

  action_fallback(AssessmentWeb.Api.ErrorController)

  def create(conn, %{"username" => u, "password" => p}) do
    with {:ok, agent} <- Accounts.get_agent_by_username_and_password(u, p),
         {:ok, jwt, _} <- Guardian.encode_and_sign(%{agent_id: agent.id}, token_type: :token) do
      conn
      |> put_status(:accepted)
      |> render("create.json", agent: agent, jwt: jwt)
    else
      {:error, msg} -> conn |> json(msg)

    # else
    #   {:error, :unauthenticated} ->
    #   {:error, message} ->
    #     conn
    #     |> put_status(401)
    #     |> render(ErrorView, "error.json", message: message)
    end
  end
end
