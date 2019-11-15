defmodule Demo.Accounts.Courier do
  use Ecto.Schema

  import Ecto.Changeset

  alias Demo.Accounts.Agent
  alias Demo.Orders.Order

  schema "couriers" do
    field :address, :string
    field :email, :string
    field :name, :string
    belongs_to :agent, Agent
    field :username, :string, virtual: true
    has_many :orders, Order

    timestamps()
  end

  @doc false
  def changeset(courier, attrs) do
    courier
    |> cast(attrs, [:name, :address, :email])
    |> validate_required([:name, :address, :email])
    |> unique_constraint(:name)
    |> unique_constraint(:address)
    |> unique_constraint(:email)
  end
end
