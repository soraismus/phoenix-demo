defmodule AssessmentWeb.AdministratorControllerTest do
  use AssessmentWeb.ConnCase

  alias Assessment.Accounts

  @invalid_attrs %{email: nil}
  @create_attrs %{ username: "some username",
                   administrator: %{
                     email: "some email",
                   },
                   credential: %{password: "some password"}
                 }

  def fixture(:administrator) do
    {:ok, %_{administrator: administrator} = agent} =
      @create_attrs
      |> Accounts.create_administrator()
    %{administrator | agent: agent}
  end

  describe "index" do
    setup [:log_in_admin]

    test "lists all administrators", %{conn: conn} do
      conn = get conn, administrator_path(conn, :index)
      assert html_response(conn, 200) =~ "Listing Administrators"
    end
  end

  describe "new administrator" do
    setup [:log_in_admin]

    test "renders form", %{conn: conn} do
      conn = get conn, administrator_path(conn, :new)
      assert html_response(conn, 200) =~ "New Administrator"
    end
  end

  describe "create administrator" do
    setup [:log_in_admin]

    test "redirects to show when data is valid", %{conn: conn} do
      response0 = post conn, administrator_path(conn, :create), agent: @create_attrs
      assert %{id: id} = redirected_params(response0)
      assert redirected_to(response0) == administrator_path(response0, :show, id)
      response1 = get conn, administrator_path(conn, :show, id)
      assert html_response(response1, 200) =~ "Show Administrator"
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post conn, administrator_path(conn, :create), agent: @invalid_attrs
      assert html_response(conn, 400) =~ "New Administrator"
    end
  end

  describe "delete administrator" do
    setup [:log_in_admin, :create_administrator]

    test "deletes chosen administrator", %{conn: conn, administrator: administrator} do
      response0 = delete conn, administrator_path(conn, :delete, administrator)
      assert redirected_to(response0) == administrator_path(response0, :index)
      response1 = get conn, administrator_path(conn, :show, administrator)
      assert redirected_to(response1) == page_path(response1, :index)
      error = "Administrator ##{administrator.id} does not exist"
      assert get_flash(response1, :error) =~ error
    end
  end

  defp create_administrator(_) do
    administrator = fixture(:administrator)
    {:ok, administrator: administrator}
  end

  defp log_in_admin(_) do
    {:ok, admin} =
      Accounts.create_administrator(%{
        username: "admin",
        administrator: %{
          email: "admin@example.com"
        },
        credential: %{
          password: "admin"
        }
      })
    subject = %{agent_id: admin.id}
    conn =
      build_conn()
      |> AssessmentWeb.Guardian.Plug.sign_in(subject)
    {:ok, conn: conn}
  end
end
