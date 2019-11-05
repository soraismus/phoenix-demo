defmodule AssessmentWeb.GuardianController do
  import Assessment.Utilities, only: [prohibit_nil: 1]
  alias Assessment.Accounts.Agent
  alias AssessmentWeb.Guardian.Plug, as: GuardianPlug
  alias AssessmentWeb.Guardian

  def get_administrator(%Agent{} = agent) do
    case agent.account_type do
      "administrator" -> {:ok, agent.administrator}
      _               -> {:error, :not_authorized}
    end
  end
  def get_administrator(%Plug.Conn{} = conn) do
    case conn.assigns.agent do
      nil -> {:error, :not_authenticated}
      agent -> get_administrator(agent)
    end
  end

  def get_account(%Agent{} = agent) do
    case agent.account_type do
      "administrator" -> {:ok, agent.administrator}
      "courier"       -> {:ok, agent.courier}
      "pharmacy"      -> {:ok, agent.pharmacy}
      _               -> {:error, :invalid_account_type}
    end
  end
  def get_account(%Plug.Conn{} = conn) do
    case conn.assigns.agent do
      nil -> {:error, :not_authenticated}
      agent -> get_account(agent)
    end
  end

  def identify_agent(%Plug.Conn{} = conn) do
    with {:ok, token} <- conn |> GuardianPlug.current_token() |> prohibit_nil(),
         {:ok, (%Agent{} = agent), _claims} <- Guardian.resource_from_token(token) do
      {:ok, agent}
    else
      _ ->
        {:error, :not_authenticated}
    end
  end
end
