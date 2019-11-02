defmodule Assessment.Accounts.Administrator do
  use Ecto.Schema
  import Ecto.Changeset
  alias Assessment.Accounts.Agent


  schema "administrators" do
    field :email, :string
    belongs_to :agent, Agent

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
