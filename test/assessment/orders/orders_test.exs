defmodule Assessment.OrdersTest do
  use Assessment.DataCase

  alias Assessment.Orders

  describe "order" do
    alias Assessment.Orders.Order

    @valid_attrs %{pickup_date: ~D[2010-04-17], pickup_time: ~T[14:00:00.000000]}
    @update_attrs %{pickup_date: ~D[2011-05-18], pickup_time: ~T[15:01:01.000000]}
    @invalid_attrs %{pickup_date: nil, pickup_time: nil}

    def order_fixture(attrs \\ %{}) do
      {:ok, order} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Orders.create_order()

      order
    end

    test "list_order/0 returns all order" do
      order = order_fixture()
      assert Orders.list_order() == [order]
    end

    test "get_order!/1 returns the order with given id" do
      order = order_fixture()
      assert Orders.get_order!(order.id) == order
    end

    test "create_order/1 with valid data creates a order" do
      assert {:ok, %Order{} = order} = Orders.create_order(@valid_attrs)
      assert order.pickup_date == ~D[2010-04-17]
      assert order.pickup_time == ~T[14:00:00.000000]
    end

    test "create_order/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Orders.create_order(@invalid_attrs)
    end

    test "update_order/2 with valid data updates the order" do
      order = order_fixture()
      assert {:ok, order} = Orders.update_order(order, @update_attrs)
      assert %Order{} = order
      assert order.pickup_date == ~D[2011-05-18]
      assert order.pickup_time == ~T[15:01:01.000000]
    end

    test "update_order/2 with invalid data returns error changeset" do
      order = order_fixture()
      assert {:error, %Ecto.Changeset{}} = Orders.update_order(order, @invalid_attrs)
      assert order == Orders.get_order!(order.id)
    end

    test "delete_order/1 deletes the order" do
      order = order_fixture()
      assert {:ok, %Order{}} = Orders.delete_order(order)
      assert_raise Ecto.NoResultsError, fn -> Orders.get_order!(order.id) end
    end

    test "change_order/1 returns a order changeset" do
      order = order_fixture()
      assert %Ecto.Changeset{} = Orders.change_order(order)
    end
  end

  describe "orders" do
    alias Assessment.Orders.Order

    @valid_attrs %{pickup_date: ~D[2010-04-17], pickup_time: ~T[14:00:00.000000]}
    @update_attrs %{pickup_date: ~D[2011-05-18], pickup_time: ~T[15:01:01.000000]}
    @invalid_attrs %{pickup_date: nil, pickup_time: nil}

    def order_fixture(attrs \\ %{}) do
      {:ok, order} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Orders.create_order()

      order
    end

    test "list_orders/0 returns all orders" do
      order = order_fixture()
      assert Orders.list_orders() == [order]
    end

    test "get_order!/1 returns the order with given id" do
      order = order_fixture()
      assert Orders.get_order!(order.id) == order
    end

    test "create_order/1 with valid data creates a order" do
      assert {:ok, %Order{} = order} = Orders.create_order(@valid_attrs)
      assert order.pickup_date == ~D[2010-04-17]
      assert order.pickup_time == ~T[14:00:00.000000]
    end

    test "create_order/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Orders.create_order(@invalid_attrs)
    end

    test "update_order/2 with valid data updates the order" do
      order = order_fixture()
      assert {:ok, order} = Orders.update_order(order, @update_attrs)
      assert %Order{} = order
      assert order.pickup_date == ~D[2011-05-18]
      assert order.pickup_time == ~T[15:01:01.000000]
    end

    test "update_order/2 with invalid data returns error changeset" do
      order = order_fixture()
      assert {:error, %Ecto.Changeset{}} = Orders.update_order(order, @invalid_attrs)
      assert order == Orders.get_order!(order.id)
    end

    test "delete_order/1 deletes the order" do
      order = order_fixture()
      assert {:ok, %Order{}} = Orders.delete_order(order)
      assert_raise Ecto.NoResultsError, fn -> Orders.get_order!(order.id) end
    end

    test "change_order/1 returns a order changeset" do
      order = order_fixture()
      assert %Ecto.Changeset{} = Orders.change_order(order)
    end
  end
end
