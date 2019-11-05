defmodule AssessmentWeb.Api.AdministratorView do
  use AssessmentWeb, :view

  def render("index.json", _params) do
    %{msg: "Hello, world."}
  end
end
