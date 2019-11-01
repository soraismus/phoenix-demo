defmodule Assessment.Accounts.Agent do
  use Ecto.Schema
  import Ecto.Changeset


  schema "agents" do
    field :username, :string

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
