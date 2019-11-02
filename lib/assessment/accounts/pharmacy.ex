defmodule Assessment.Accounts.Pharmacy do
  use Ecto.Schema
  import Ecto.Changeset
  alias Assessment.Accounts.Agent


  schema "pharmacies" do
    field :address, :string
    field :email, :string
    field :name, :string
    belongs_to :agent, Agent

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
