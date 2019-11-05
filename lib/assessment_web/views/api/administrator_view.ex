defmodule AssessmentWeb.Api.AdministratorView do
  use AssessmentWeb, :view
  alias Assessment.Accounts.Administrator
  alias Assessment.Utilities
  alias Assessment.Utilities.ToJson

  def render("index.json", %{administrators: administrators}) do
    %{
      count: length(administrators),
      administrators: ToJson.to_json(administrators),
    }
  end

  def render("show.json", %{administrator: administrator}) do
    %{administrator: ToJson.to_json(administrator)}
  end

  defimpl ToJson, for: Administrator do
    def to_json(%Administrator{} = administrator) do
      administrator
      |> Utilities.to_json([:id, :username, :email])
    end
  end
end
