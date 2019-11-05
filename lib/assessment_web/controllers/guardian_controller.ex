defmodule AssessmentWeb.GuardianController do
  import Assessment.Utilities, only: [prohibit_nil: 1]
  import AssessmentWeb.Router.Helpers, only: [page_path: 2]
  import Phoenix.Controller, only: [put_flash: 3, redirect: 2]
  import Plug.Conn, only: [halt: 1]
  alias Assessment.Accounts.Agent
  alias AssessmentWeb.Guardian.Plug, as: GuardianPlug
  alias AssessmentWeb.Guardian

  def authenticate_administrator(%Plug.Conn{} = conn, _) do
    agent = conn.assigns.agent
    if agent && agent.account_type == "administrator" do
      conn
    else
      conn
      |> put_flash(:error, "not authorized")
      |> redirect(to: page_path(conn, :index))
      |> halt()
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
