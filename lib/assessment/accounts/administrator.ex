defmodule Assessment.Accounts.Administrator do
  use Ecto.Schema
  import Ecto.Changeset
  alias Assessment.Accounts.Agent


  schema "administrators" do
    field :email, :string
    belongs_to :agent, Agent
    field :username, :string, virtual: true

    timestamps()
  end

  @doc false
  def changeset(administrator, attrs) do
    administrator
    |> cast(attrs, [:email, :agent_id])
    |> validate_required([:email, :agent_id])
    |> unique_constraint(:email)
    |> unique_constraint(:agent_id)
    |> foreign_key_constraint(:agent_id)
  end
end
