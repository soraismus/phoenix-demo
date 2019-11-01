defmodule Assessment.AccountsTest do
  use Assessment.DataCase

  alias Assessment.Accounts

  describe "agents" do
    alias Assessment.Accounts.Agent

    @valid_attrs %{username: "some username"}
    @update_attrs %{username: "some updated username"}
    @invalid_attrs %{username: nil}

    def agent_fixture(attrs \\ %{}) do
      {:ok, agent} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Accounts.create_agent()

      agent
    end

    test "list_agents/0 returns all agents" do
      agent = agent_fixture()
      assert Accounts.list_agents() == [agent]
    end

    test "get_agent!/1 returns the agent with given id" do
      agent = agent_fixture()
      assert Accounts.get_agent!(agent.id) == agent
    end

    test "create_agent/1 with valid data creates a agent" do
      assert {:ok, %Agent{} = agent} = Accounts.create_agent(@valid_attrs)
      assert agent.username == "some username"
    end

    test "create_agent/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Accounts.create_agent(@invalid_attrs)
    end

    test "update_agent/2 with valid data updates the agent" do
      agent = agent_fixture()
      assert {:ok, agent} = Accounts.update_agent(agent, @update_attrs)
      assert %Agent{} = agent
      assert agent.username == "some updated username"
    end

    test "update_agent/2 with invalid data returns error changeset" do
      agent = agent_fixture()
      assert {:error, %Ecto.Changeset{}} = Accounts.update_agent(agent, @invalid_attrs)
      assert agent == Accounts.get_agent!(agent.id)
    end

    test "delete_agent/1 deletes the agent" do
      agent = agent_fixture()
      assert {:ok, %Agent{}} = Accounts.delete_agent(agent)
      assert_raise Ecto.NoResultsError, fn -> Accounts.get_agent!(agent.id) end
    end

    test "change_agent/1 returns a agent changeset" do
      agent = agent_fixture()
      assert %Ecto.Changeset{} = Accounts.change_agent(agent)
    end
  end

  describe "administrators" do
    alias Assessment.Accounts.Administrator

    @valid_attrs %{email: "some email"}
    @update_attrs %{email: "some updated email"}
    @invalid_attrs %{email: nil}

    def administrator_fixture(attrs \\ %{}) do
      {:ok, administrator} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Accounts.create_administrator()

      administrator
    end

    test "list_administrators/0 returns all administrators" do
      administrator = administrator_fixture()
      assert Accounts.list_administrators() == [administrator]
    end

    test "get_administrator!/1 returns the administrator with given id" do
      administrator = administrator_fixture()
      assert Accounts.get_administrator!(administrator.id) == administrator
    end

    test "create_administrator/1 with valid data creates a administrator" do
      assert {:ok, %Administrator{} = administrator} = Accounts.create_administrator(@valid_attrs)
      assert administrator.email == "some email"
    end

    test "create_administrator/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Accounts.create_administrator(@invalid_attrs)
    end

    test "update_administrator/2 with valid data updates the administrator" do
      administrator = administrator_fixture()
      assert {:ok, administrator} = Accounts.update_administrator(administrator, @update_attrs)
      assert %Administrator{} = administrator
      assert administrator.email == "some updated email"
    end

    test "update_administrator/2 with invalid data returns error changeset" do
      administrator = administrator_fixture()
      assert {:error, %Ecto.Changeset{}} = Accounts.update_administrator(administrator, @invalid_attrs)
      assert administrator == Accounts.get_administrator!(administrator.id)
    end

    test "delete_administrator/1 deletes the administrator" do
      administrator = administrator_fixture()
      assert {:ok, %Administrator{}} = Accounts.delete_administrator(administrator)
      assert_raise Ecto.NoResultsError, fn -> Accounts.get_administrator!(administrator.id) end
    end

    test "change_administrator/1 returns a administrator changeset" do
      administrator = administrator_fixture()
      assert %Ecto.Changeset{} = Accounts.change_administrator(administrator)
    end
  end

  describe "pharmacies" do
    alias Assessment.Accounts.Pharmacy

    @valid_attrs %{address: "some address", email: "some email", name: "some name"}
    @update_attrs %{address: "some updated address", email: "some updated email", name: "some updated name"}
    @invalid_attrs %{address: nil, email: nil, name: nil}

    def pharmacy_fixture(attrs \\ %{}) do
      {:ok, pharmacy} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Accounts.create_pharmacy()

      pharmacy
    end

    test "list_pharmacies/0 returns all pharmacies" do
      pharmacy = pharmacy_fixture()
      assert Accounts.list_pharmacies() == [pharmacy]
    end

    test "get_pharmacy!/1 returns the pharmacy with given id" do
      pharmacy = pharmacy_fixture()
      assert Accounts.get_pharmacy!(pharmacy.id) == pharmacy
    end

    test "create_pharmacy/1 with valid data creates a pharmacy" do
      assert {:ok, %Pharmacy{} = pharmacy} = Accounts.create_pharmacy(@valid_attrs)
      assert pharmacy.address == "some address"
      assert pharmacy.email == "some email"
      assert pharmacy.name == "some name"
    end

    test "create_pharmacy/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Accounts.create_pharmacy(@invalid_attrs)
    end

    test "update_pharmacy/2 with valid data updates the pharmacy" do
      pharmacy = pharmacy_fixture()
      assert {:ok, pharmacy} = Accounts.update_pharmacy(pharmacy, @update_attrs)
      assert %Pharmacy{} = pharmacy
      assert pharmacy.address == "some updated address"
      assert pharmacy.email == "some updated email"
      assert pharmacy.name == "some updated name"
    end

    test "update_pharmacy/2 with invalid data returns error changeset" do
      pharmacy = pharmacy_fixture()
      assert {:error, %Ecto.Changeset{}} = Accounts.update_pharmacy(pharmacy, @invalid_attrs)
      assert pharmacy == Accounts.get_pharmacy!(pharmacy.id)
    end

    test "delete_pharmacy/1 deletes the pharmacy" do
      pharmacy = pharmacy_fixture()
      assert {:ok, %Pharmacy{}} = Accounts.delete_pharmacy(pharmacy)
      assert_raise Ecto.NoResultsError, fn -> Accounts.get_pharmacy!(pharmacy.id) end
    end

    test "change_pharmacy/1 returns a pharmacy changeset" do
      pharmacy = pharmacy_fixture()
      assert %Ecto.Changeset{} = Accounts.change_pharmacy(pharmacy)
    end
  end

  describe "couriers" do
    alias Assessment.Accounts.Courier

    @valid_attrs %{address: "some address", email: "some email", name: "some name"}
    @update_attrs %{address: "some updated address", email: "some updated email", name: "some updated name"}
    @invalid_attrs %{address: nil, email: nil, name: nil}

    def courier_fixture(attrs \\ %{}) do
      {:ok, courier} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Accounts.create_courier()

      courier
    end

    test "list_couriers/0 returns all couriers" do
      courier = courier_fixture()
      assert Accounts.list_couriers() == [courier]
    end

    test "get_courier!/1 returns the courier with given id" do
      courier = courier_fixture()
      assert Accounts.get_courier!(courier.id) == courier
    end

    test "create_courier/1 with valid data creates a courier" do
      assert {:ok, %Courier{} = courier} = Accounts.create_courier(@valid_attrs)
      assert courier.address == "some address"
      assert courier.email == "some email"
      assert courier.name == "some name"
    end

    test "create_courier/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Accounts.create_courier(@invalid_attrs)
    end

    test "update_courier/2 with valid data updates the courier" do
      courier = courier_fixture()
      assert {:ok, courier} = Accounts.update_courier(courier, @update_attrs)
      assert %Courier{} = courier
      assert courier.address == "some updated address"
      assert courier.email == "some updated email"
      assert courier.name == "some updated name"
    end

    test "update_courier/2 with invalid data returns error changeset" do
      courier = courier_fixture()
      assert {:error, %Ecto.Changeset{}} = Accounts.update_courier(courier, @invalid_attrs)
      assert courier == Accounts.get_courier!(courier.id)
    end

    test "delete_courier/1 deletes the courier" do
      courier = courier_fixture()
      assert {:ok, %Courier{}} = Accounts.delete_courier(courier)
      assert_raise Ecto.NoResultsError, fn -> Accounts.get_courier!(courier.id) end
    end

    test "change_courier/1 returns a courier changeset" do
      courier = courier_fixture()
      assert %Ecto.Changeset{} = Accounts.change_courier(courier)
    end
  end
end
