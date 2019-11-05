defmodule AssessmentWeb.Api.CourierView do
  use AssessmentWeb, :view
  alias Assessment.Accounts.Courier
  alias Assessment.Utilities
  alias Assessment.Utilities.ToJson

  def render("create.json", %{courier: courier}) do
    %{created: %{courier: ToJson.to_json(courier)}}
  end

  def render("index.json", %{couriers: couriers}) do
    %{
      count: length(couriers),
      couriers: ToJson.to_json(couriers),
    }
  end

  def render("show.json", %{courier: courier}) do
    %{courier: ToJson.to_json(courier)}
  end

  defimpl ToJson, for: Courier do
    def to_json(%Courier{} = courier) do
      courier
      |> Utilities.to_json([:id, :name, :username, :email])
    end
  end
end
