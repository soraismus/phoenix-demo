defmodule AssessmentWeb.Api.AdministratorController do
  use AssessmentWeb, :controller
  alias Assessment.Accounts

  def index(conn, _params) do
    administrators = Accounts.list_administrators()
    render(conn, "index.json", administrators: administrators)
  end
end
