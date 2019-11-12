defmodule Assessment.OrderStatesTest do
  use Assessment.DataCase

  alias Assessment.OrderStates

  describe "order_states" do
    alias Assessment.OrderStates.OrderState

    @valid_attrs %{description: "some description"}
    @update_attrs %{description: "some updated description"}
    @invalid_attrs %{description: nil}

    def order_state_fixture(attrs \\ %{}) do
      {:ok, order_state} =
        attrs
        |> Enum.into(@valid_attrs)
        |> OrderStates.create_order_state()

      order_state
    end

    test "list_order_states/0 returns all order_states" do
      order_state = order_state_fixture()
      assert OrderStates.list_order_states() == [order_state]
    end

    test "get_order_state/1 returns the order_state with given id" do
      order_state = order_state_fixture()
      assert OrderStates.get_order_state(order_state.id) |> elem(1) == order_state
    end

    test "create_order_state/1 with valid data creates a order_state" do
      assert {:ok, %OrderState{} = order_state} = OrderStates.create_order_state(@valid_attrs)
      assert order_state.description == "some description"
    end

    test "create_order_state/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = OrderStates.create_order_state(@invalid_attrs)
    end

    test "update_order_state/2 with valid data updates the order_state" do
      order_state = order_state_fixture()
      assert {:ok, order_state} = OrderStates.update_order_state(order_state, @update_attrs)
      assert %OrderState{} = order_state
      assert order_state.description == "some updated description"
    end

    test "update_order_state/2 with invalid data returns error changeset" do
      order_state = order_state_fixture()
      assert {:error, %Ecto.Changeset{}} = OrderStates.update_order_state(order_state, @invalid_attrs)
      assert order_state == OrderStates.get_order_state(order_state.id) |> elem(1)
    end

    test "delete_order_state/1 deletes the order_state" do
      order_state = order_state_fixture()
      assert {:ok, %OrderState{}} = OrderStates.delete_order_state(order_state)
      assert {:error, :no_resource} = OrderStates.get_order_state(order_state.id)
    end

    test "change_order_state/1 returns a order_state changeset" do
      order_state = order_state_fixture()
      assert %Ecto.Changeset{} = OrderStates.change_order_state(order_state)
    end
  end
end
