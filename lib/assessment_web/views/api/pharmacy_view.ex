defmodule AssessmentWeb.Api.PharmacyView do
  use AssessmentWeb, :view
  alias Assessment.Accounts.Pharmacy
  alias Assessment.Utilities
  alias Assessment.Utilities.ToJson

  def render("index.json", %{pharmacies: pharmacies}) do
    %{
      count: length(pharmacies),
      pharmacies: ToJson.to_json(pharmacies),
    }
  end

  def render("show.json", %{pharmacy: pharmacy}) do
    %{pharmacy: ToJson.to_json(pharmacy)}
  end

  defimpl ToJson, for: Pharmacy do
    def to_json(%Pharmacy{} = pharmacy) do
      pharmacy
      |> Utilities.to_json([:id, :name, :username, :email])
    end
  end
end
