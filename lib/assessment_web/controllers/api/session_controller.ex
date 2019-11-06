defmodule AssessmentWeb.Api.SessionController do
  use AssessmentWeb, :controller
  alias Assessment.Sessions
  alias AssessmentWeb.Guardian

  action_fallback(AssessmentWeb.Api.ErrorController)

  def create(conn, %{"username" => u, "password" => p}) do
    with {:ok, agent} <- Sessions.get_agent_by_username_and_password(u, p),
         {:ok, jwt, _} <- Guardian.encode_and_sign(%{agent_id: agent.id}, token_type: :token) do
      conn
      |> put_status(:accepted)
      |> render("create.json", agent: agent, jwt: jwt)
    else
      {:error, msg} -> conn |> json(%{error: msg})

    # else
    #   {:error, :unauthenticated} ->
    #   {:error, message} ->
    #     conn
    #     |> put_status(401)
    #     |> render(ErrorView, "error.json", message: message)
    end
  end
end
