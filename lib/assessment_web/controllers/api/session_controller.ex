defmodule AssessmentWeb.Api.SessionController do
  use AssessmentWeb, :controller
  import AssessmentWeb.Api.ControllerUtilities, only: [internal_error: 1]
  alias Assessment.Sessions
  alias AssessmentWeb.Guardian

  def create(conn, %{"username" => u, "password" => p}) do
    with {:ok, agent} <- Sessions.get_agent_by_username_and_password(u, p),
         {:ok, jwt, _} <- get_token(agent) do
      conn
      |> put_status(:accepted)
      |> render("create.json", agent: agent, jwt: jwt)
    else
      {:error, :invalid_claims} ->
        conn
        |> internal_error("SEIC")
      {:error, :invalid_resource} ->
        conn
        |> internal_error("SEIR")
      {:error, :unauthenticated} ->
        conn
        |> resource_error(
              "login attempt",
              "invalid username/password combination",
              :unauthorized)
      _ ->
        conn
        |> internal_error("SECR")
    end
  end

  defp get_token(%{id: id}) do
    Guardian.encode_and_sign(%{agent_id: id}, token_type: :token)
  end
end
