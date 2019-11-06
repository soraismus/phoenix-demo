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
    else
      {:error, :invalid_claims} ->
        conn
        |> resource_error("Internal error", "Error code #1100")
      {:error, :invalid_resource} ->
        conn
        |> resource_error("Internal error", "Error code #1200")
      {:error, :unauthenticated} ->
        conn
        |> resource_error(
              "login attempt",
              "invalid username/password combination",
              :unauthorized)
    end
  end

  defp get_token(%{id: id}) do
    Guardian.encode_and_sign(%{agent_id: id}, token_type: :token)
  end

  defp resource_error(conn, resource, msg, status \\ 400) do
    conn
    |> put_status(status)
    |> json(%{errors: %{resource => [msg]}})
  end
end
