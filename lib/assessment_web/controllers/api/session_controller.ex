defmodule AssessmentWeb.Api.SessionController do
  use AssessmentWeb, :controller
  alias Assessment.Sessions
  alias AssessmentWeb.Guardian

  action_fallback(AssessmentWeb.Api.ErrorController)

  def create(conn, %{"username" => u, "password" => p}) do
    with {:ok, agent} <- Sessions.get_agent_by_username_and_password(u, p),
         {:ok, jwt, _} <- get_token(agent) do
      conn
      |> put_status(:accepted)
      |> render("create.json", agent: agent, jwt: jwt)
    end
  end

  defp get_token(%{id: id}) do
    Guardian.encode_and_sign(%{agent_id: id}, token_type: :token)
  end
end
