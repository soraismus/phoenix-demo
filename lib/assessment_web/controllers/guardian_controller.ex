defmodule AssessmentWeb.GuardianController do
  import Assessment.Utilities, only: [prohibit_nil: 1]
  alias Assessment.Accounts.Agent
  alias AssessmentWeb.Guardian.Plug, as: GuardianPlug
  alias AssessmentWeb.Guardian

  def identify_agent(%Plug.Conn{} = conn) do
    with {:ok, token} <- conn |> GuardianPlug.current_token() |> prohibit_nil(),
         {:ok, agent, _claims} <- Guardian.resource_from_token(token) do
      {:ok, agent}
    else
      _ ->
        {:error, :not_authenticated}
    end
  end

  def identify_administrator(%Agent{} = agent) do
    identify_account(agent, "administrator")
  end

  def identify_courier(%Agent{} = agent) do
    identify_account(agent, "courier")
  end

  def identify_pharmacy(%Agent{} = agent) do
    identify_account(agent, "pharmacy")
  end

  defp identify_account(agent, account_type) do
    case agent.account_type do
      ^account_type -> {:ok, agent[String.to_atom(account_type)]}
      _ -> {:error, :not_authorized}
    end
  end
end
