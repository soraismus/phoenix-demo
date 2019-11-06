defmodule AssessmentWeb.Api.SessionView do
  use AssessmentWeb, :view
  alias Assessment.Accounts.Agent
  alias Assessment.Utilities
  alias Assessment.Utilities.ToJson

  def render("create.json", %{agent: agent, jwt: jwt}) do
    %{session: %{user: ToJson.to_json(agent), token: jwt}}
  end

  defimpl ToJson, for: Agent do
    def to_json(%Agent{} = agent) do
      agent
      |> Utilities.to_json([:username])
    end
  end
end
