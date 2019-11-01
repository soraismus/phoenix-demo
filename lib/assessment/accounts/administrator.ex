defmodule Assessment.Accounts.Administrator do
  use Ecto.Schema
  import Ecto.Changeset


  schema "administrators" do
    field :email, :string
    field :agent_id, :id

    timestamps()
  end

  @doc false
  def changeset(administrator, attrs) do
    administrator
    |> cast(attrs, [:email])
    |> validate_required([:email])
    |> unique_constraint(:email)
  end
end
