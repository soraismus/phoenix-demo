defmodule Assessment.Accounts.Credential do
  use Ecto.Schema
  import Ecto.Changeset
  alias Assessment.Accounts.Agent


  schema "credentials" do
    field :password_digest, :string
    field :password, :string, virtual: true
    belongs_to :agent, Agent

    timestamps()
  end

  @doc false
  def changeset(credential, attrs) do
    credential
    |> cast(attrs, [:password])
    |> validate_required([:password])
  end
end
