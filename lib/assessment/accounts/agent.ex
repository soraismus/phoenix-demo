defmodule Assessment.Accounts.Agent do
  use Ecto.Schema
  import Ecto.Changeset
  alias Assessment.Accounts.{Administrator,Courier,Pharmacy}


  schema "agents" do
    field :username, :string
    has_one :administrator, Administrator
    has_one :courier, Courier
    has_one :pharmacy, Pharmacy

    timestamps()
  end

  @doc false
  def changeset(agent, attrs) do
    agent
    |> cast(attrs, [:username])
    |> validate_required([:username])
    |> unique_constraint(:username)
  end
end
