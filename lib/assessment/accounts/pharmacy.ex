defmodule Assessment.Accounts.Pharmacy do
  use Ecto.Schema
  import Ecto.Changeset
  alias Assessment.Accounts.Agent


  schema "pharmacies" do
    field :address, :string
    field :email, :string
    field :name, :string
    belongs_to :agent, Agent
    field :username, :string, virtual: true

    timestamps()
  end

  @doc false
  def changeset(pharmacy, attrs) do
    pharmacy
    |> cast(attrs, [:name, :address, :email, :agent_id])
    |> validate_required([:name, :address, :email, :agent_id])
    |> unique_constraint(:name)
    |> unique_constraint(:address)
    |> unique_constraint(:email)
    |> unique_constraint(:agent_id)
    |> foreign_key_constraint(:agent_id)
  end
end
