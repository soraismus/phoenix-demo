defmodule Assessment.DataCase do
  @moduledoc """
  This module defines the setup for tests requiring
  access to the application's data layer.

  You may define functions here to be used as helpers in
  your tests.

  Finally, if the test case interacts with the database,
  it cannot be async. For this reason, every test runs
  inside a transaction which is reset at the beginning
  of the test unless the test case is marked as async.
  """

  use ExUnit.CaseTemplate

  using do
    quote do
      alias Assessment.Repo

      import Ecto
      import Ecto.Changeset
      import Ecto.Query
      import Assessment.DataCase
    end
  end

  setup tags do
    :ok = Ecto.Adapters.SQL.Sandbox.checkout(Assessment.Repo)

    unless tags[:async] do
      Ecto.Adapters.SQL.Sandbox.mode(Assessment.Repo, {:shared, self()})
    end

    :ok
  end

  @doc """
  A helper that transform changeset errors to a map of messages.

      assert {:error, changeset} = Accounts.create_user(%{password: "short"})
      assert "password is too short" in errors_on(changeset).password
      assert %{password: ["password is too short"]} = errors_on(changeset)

  """
  def errors_on(changeset) do
    Ecto.Changeset.traverse_errors(changeset, fn {message, opts} ->
      Enum.reduce(opts, message, fn {key, value}, acc ->
        String.replace(acc, "%{#{key}}", to_string(value))
      end)
    end)
  end

  alias Assessment.{Accounts,Orders,Patients}

  @administrator_attrs %{ username: "some username",
                          administrator: %{
                            email: "some email",
                          },
                          credential: %{password: "some password"}
                        }

  @courier_attrs %{ "courier" => %{
                      "name" => "some name",
                      "email" => "some email",
                      "address" => "some address",
                    },
                    "credential" => %{"password" => "some password"}
                  }

  @order_attrs %{ "order_state_description" => "active",
                  "pickup_date" => "2010-04-17",
                  "pickup_time" => "14:00",
                }

  @patient_attrs %{"name" => "some name", "address" => "some address"}

  @pharmacy_attrs %{ "pharmacy" => %{
                       "name" => "some name",
                       "email" => "some email",
                       "address" => "some address",
                     },
                     "credential" => %{"password" => "some password"}
                   }

  def fixture(:administrator) do
    {:ok, %_{administrator: administrator} = agent} =
      Accounts.create_administrator(@administrator_attrs)
    %{administrator | agent: agent}
  end

  def fixture(:courier) do
    {:ok, %_{courier: courier} = agent} =
      @courier_attrs
      |> Enum.into(%{"username" => get_username()})
      |> Accounts.create_courier()
    %{courier | agent: agent}
  end

  def fixture(:order) do
    patient = fixture(:patient)
    courier = fixture(:courier)
    pharmacy = fixture(:pharmacy)
    {:ok, order} =
      %{ "patient_id" => patient.id,
         "courier_id" => courier.id,
         "pharmacy_id" => pharmacy.id,
       }
      |> Enum.into(@order_attrs)
      |> Orders.create_order()
    order
  end

  def fixture(:patient) do
    {:ok, patient} = Patients.create_patient(@patient_attrs)
    patient
  end

  def fixture(:pharmacy) do
    {:ok, %_{pharmacy: pharmacy} = agent} =
      @pharmacy_attrs
      |> Enum.into(%{"username" => get_username()})
      |> Accounts.create_pharmacy()
    %{pharmacy | agent: agent}
  end

  defp get_username() do
    :rand.uniform(1000000000) |> to_string()
  end
end
