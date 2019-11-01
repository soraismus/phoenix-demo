defmodule Assessment.Accounts.Pharmacy do
  use Ecto.Schema
  import Ecto.Changeset


  schema "pharmacies" do
    field :address, :string
    field :email, :string
    field :name, :string
    field :agent_id, :id

    timestamps()
  end

  @doc false
  def changeset(pharmacy, attrs) do
    pharmacy
    |> cast(attrs, [:name, :address, :email])
    |> validate_required([:name, :address, :email])
    |> unique_constraint(:name)
    |> unique_constraint(:address)
    |> unique_constraint(:email)
  end
end
