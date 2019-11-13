defmodule AssessmentWeb.Api.SessionController do
  use AssessmentWeb, :controller

  import AssessmentWeb.Api.ControllerUtilities,
    only: [ internal_error: 2,
            match_error: 2,
            resource_error: 4,
          ]

  alias Assessment.Sessions
  alias AssessmentWeb.Guardian

  @accepted :accepted
  @error :error
  @forbidden :forbidden
  @invalid_claims :invalid_claims
  @invalid_resource :invalid_resource
  @ok :ok
  @token :token
  @unauthenticated :unauthenticated
  @unauthorized :unauthorized

  @doc """
    Callback required by Guardian
  """
  def auth_error(conn, {_type, _reason}, _opts) do
    note = "(Consider resetting Guardian's 'ttl' value in 'config.ex'.)"
    msg = "Expired credentials #{note}"
    conn
    |> put_status(@forbidden)
    |> json(%{errors: %{request: [msg]}})
  end
  def auth_error(conn, _, _), do: conn |> internal_error("SEAE_A")

  def create(conn, %{"username" => u, "password" => p}) do
    with {@ok, agent} <- Sessions.get_agent_by_username_and_password(u, p),
         {@ok, jwt, _} <- get_token(agent) do
      conn
      |> put_status(@accepted)
      |> render("create.json", agent: agent, jwt: jwt)
    else
      {@error, @invalid_claims} ->
        conn
        |> internal_error("SECRIC_A")
      {@error, @invalid_resource} ->
        conn
        |> internal_error("SECRIR_A")
      {@error, @unauthenticated} ->
        conn
        |> resource_error(
              "login attempt",
              "invalid username/password combination",
              @unauthorized)
      _ ->
        conn
        |> internal_error("SECR_A")
    end
  end
  def create(conn, _) do
    conn
    |> match_error("to create a session")
  end

  defp get_token(%{id: id}) do
    Guardian.encode_and_sign(%{agent_id: id}, token_type: @token)
  end
end
