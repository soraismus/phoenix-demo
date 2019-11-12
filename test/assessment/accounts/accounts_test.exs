defmodule Assessment.AccountsTest do
  use Assessment.DataCase

  alias Assessment.Accounts
  alias Assessment.Accounts.{Administrator,Agent,Courier,Pharmacy}

  def equiv?([], []), do: true
  def equiv?([_ | _], []), do: false
  def equiv?([], [_ | _]), do: false
  def equiv?([value0 | values0], [value1 | values1]) do
    equiv?(value0, value1)
      && equiv?(values0, values1)
  end
  def equiv?(%Administrator{} = admin0, %Administrator{} = admin1) do
    admin0.id == admin1.id
      && admin0.email == admin1.email
  end
  def equiv?(%Pharmacy{} = pharmacy0, %Pharmacy{} = pharmacy1) do
    pharmacy0.id == pharmacy1.id
      && pharmacy0.name == pharmacy1.name
      && pharmacy0.email == pharmacy1.email
      && pharmacy0.address == pharmacy1.address
  end
  def equiv?(%Courier{} = courier0, %Courier{} = courier1) do
    courier0.id == courier1.id
      && courier0.name == courier1.name
      && courier0.email == courier1.email
      && courier0.address == courier1.address
  end

  describe "administrators" do
    alias Assessment.Accounts.Administrator

    @valid_attrs %{ username: "some username",
                    administrator: %{
                      email: "some email",
                    },
                    credential: %{password: "some password"}
                  }

    @invalid_attrs %{email: nil}

    def administrator_fixture(attrs \\ %{}) do
      {:ok, %Agent{administrator: administrator}} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Accounts.create_administrator()
      %{administrator | agent: %Agent{}}
    end

    test "list_administrators/0 returns all administrators" do
      administrator = administrator_fixture()
      assert(equiv?(Accounts.list_administrators(), [administrator]))
    end

    test "get_administrator/1 returns the administrator with given id" do
      administrator0 = administrator_fixture()
      {:ok, administrator1} = Accounts.get_administrator(administrator0.id)
      assert(equiv?(administrator0, administrator1))
    end

    test "create_administrator/1 with valid data creates a administrator" do
      assert {:ok, %Administrator{} = administrator} = Accounts.create_administrator(@valid_attrs)
      assert administrator.email == "some email"
    end

    test "create_administrator/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Accounts.create_administrator(@invalid_attrs)
    end

    test "delete_administrator/1 deletes the administrator" do
      administrator = administrator_fixture()
      assert {:ok, %Administrator{}} = Accounts.delete_administrator(administrator)
      assert {:error, :no_resource} = Accounts.get_administrator(administrator.id)
    end

    test "change_administrator/0 returns a administrator changeset" do
      assert %Ecto.Changeset{} = Accounts.change_administrator()
    end
  end

  describe "pharmacies" do
    alias Assessment.Accounts.Pharmacy

    @valid_attrs %{ username: "some username",
                    pharmacy: %{
                      address: "some address",
                      email: "some email",
                      name: "some name",
                    },
                    credential: %{password: "some password"}
                  }
    @invalid_attrs %{address: nil, email: nil, name: nil}

    def pharmacy_fixture(attrs \\ %{}) do
      {:ok, %Agent{pharmacy: pharmacy}} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Accounts.create_pharmacy()
      %{pharmacy | agent: %Agent{}}
    end

    test "list_pharmacies/0 returns all pharmacies" do
      pharmacy = pharmacy_fixture()
      assert(equiv?(Accounts.list_pharmacies(), [pharmacy]))
    end

    test "get_pharmacy/1 returns the pharmacy with given id" do
      pharmacy0 = pharmacy_fixture()
      {:ok, pharmacy1} = Accounts.get_pharmacy(pharmacy0.id)
      assert(equiv?(pharmacy0, pharmacy1))
    end

    test "create_pharmacy/1 with valid data creates a pharmacy" do
      assert {:ok, %Agent{pharmacy: pharmacy}} = Accounts.create_pharmacy(@valid_attrs)
      assert pharmacy.address == "some address"
      assert pharmacy.email == "some email"
      assert pharmacy.name == "some name"
    end

    test "create_pharmacy/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Accounts.create_pharmacy(@invalid_attrs)
    end

    test "delete_pharmacy/1 deletes the pharmacy" do
      pharmacy = pharmacy_fixture()
      assert {:ok, %Pharmacy{}} = Accounts.delete_pharmacy(pharmacy)
      assert {:error, :no_resource} = Accounts.get_pharmacy(pharmacy.id)
    end

    test "change_pharmacy/0 returns a pharmacy changeset" do
      assert %Ecto.Changeset{} = Accounts.change_pharmacy()
    end
  end

  describe "couriers" do
    alias Assessment.Accounts.Courier

    @valid_attrs %{ username: "some username",
                    courier: %{
                      address: "some address",
                      email: "some email",
                      name: "some name",
                    },
                    credential: %{password: "some password"}
                  }
    @invalid_attrs %{address: nil, email: nil, name: nil}

    def courier_fixture(attrs \\ %{}) do
      {:ok, %Agent{courier: courier}} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Accounts.create_courier()
      %{courier | agent: %Agent{}}
    end

    test "list_couriers/0 returns all couriers" do
      courier = courier_fixture()
      assert(equiv?(Accounts.list_couriers(), [courier]))
    end

    test "get_courier/1 returns the courier with given id" do
      courier0 = courier_fixture()
      {:ok, courier1} = Accounts.get_courier(courier0.id)
      assert(equiv?(courier0, courier1))
    end

    test "create_courier/1 with valid data creates a courier" do
      assert {:ok, %Agent{courier: courier}} = Accounts.create_courier(@valid_attrs)
      assert courier.address == "some address"
      assert courier.email == "some email"
      assert courier.name == "some name"
    end

    test "create_courier/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Accounts.create_courier(@invalid_attrs)
    end

    test "delete_courier/1 deletes the courier" do
      courier = courier_fixture()
      assert {:ok, %Courier{}} = Accounts.delete_courier(courier)
      assert {:error, :no_resource} = Accounts.get_courier(courier.id)
    end

    test "change_courier/0 returns a courier changeset" do
      assert %Ecto.Changeset{} = Accounts.change_courier()
    end
  end
end
