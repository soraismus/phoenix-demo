defmodule AssessmentWeb.Api.AdministratorController do
  use AssessmentWeb, :controller
  alias Assessment.Accounts

  def index(conn, _params) do
    administrators = Accounts.list_administrators()
    conn
    |> render("index.json", administrators: administrators)
  end

  def show(conn, %{"id" => id}) do
    with {:ok, administrator} <- Accounts.get_administrator(id) do
      conn
      |> render("show.json", administrator: administrator)
    end
  end
end
