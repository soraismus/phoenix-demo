defmodule AssessmentWeb.GuardianController do
  import Utilities, only: [prohibit_nil: 1]

  alias Assessment.Accounts.Agent
  alias AssessmentWeb.Guardian.Plug, as: GuardianPlug
  alias AssessmentWeb.Guardian
  alias Plug.Conn

  @error :error
  @not_authenticated :not_authenticated
  @not_authorized :not_authorized
  @ok :ok

  def authenticate_administrator(%Conn{} = conn) do
    with {@ok, agent} <- identify_agent(conn) do
      case agent.account_type do
        "administrator" -> {@ok, agent.administrator}
        _ -> {@error, @not_authorized}
      end
    end
  end

  def authenticate_agent(%Conn{} = conn) do
    identify_agent(conn)
  end

  def identify_agent(%Conn{} = conn) do
    with {@ok, token} <- conn |> GuardianPlug.current_token() |> prohibit_nil(),
         {@ok, (%Agent{} = agent), _claims} <- Guardian.resource_from_token(token) do
      {@ok, agent}
    else
      _ ->
        {@error, @not_authenticated}
    end
  end
end
