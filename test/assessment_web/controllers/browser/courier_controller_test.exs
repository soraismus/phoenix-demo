defmodule AssessmentWeb.Browser.CourierControllerTest do
  use AssessmentWeb.ConnCase

  import AssessmentWeb.Browser.ConnCase, only: [log_in_admin: 1]

  alias Assessment.Accounts

  @invalid_attrs %{address: nil, email: nil, name: nil}
  @create_attrs %{ username: "some username",
                   courier: %{
                     name: "some name",
                     email: "some email",
                     address: "some address",
                   },
                   credential: %{password: "some password"}
                 }

  def fixture(:courier) do
    {:ok, %_{courier: courier} = agent} =
      Accounts.create_courier(@create_attrs)
    %{courier | agent: agent}
  end

  describe "index" do
    setup [:log_in_admin]

    test "lists all couriers", %{conn: conn} do
      conn = get conn, courier_path(conn, :index)
      assert html_response(conn, 200) =~ "Listing Couriers"
    end
  end

  describe "new courier" do
    setup [:log_in_admin]

    test "renders form", %{conn: conn} do
      conn = get conn, courier_path(conn, :new)
      assert html_response(conn, 200) =~ "New Courier"
    end
  end

  describe "create courier" do
    setup [:log_in_admin]

    test "redirects to show when data is valid", %{conn: conn} do
      response0 = post conn, courier_path(conn, :create), agent: @create_attrs
      assert %{id: id} = redirected_params(response0)
      assert redirected_to(response0) == courier_path(response0, :show, id)
      response1 = get conn, courier_path(conn, :show, id)
      assert html_response(response1, 200) =~ "Show Courier"
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post conn, courier_path(conn, :create), agent: @invalid_attrs
      assert html_response(conn, 200) =~ "New Courier"
    end
  end

  describe "delete courier" do
    setup [:log_in_admin, :create_courier]

    test "deletes chosen courier", %{conn: conn, courier: courier} do
      response0 = delete conn, courier_path(conn, :delete, courier)
      assert redirected_to(response0) == courier_path(response0, :index)
      response1 = get conn, courier_path(conn, :show, courier)
      assert redirected_to(response1) == page_path(response1, :index)
      error = "Courier ##{courier.id} does not exist"
      assert get_flash(response1, :error) =~ error
    end
  end

  defp create_courier(_) do
    courier = fixture(:courier)
    {:ok, courier: courier}
  end
end
