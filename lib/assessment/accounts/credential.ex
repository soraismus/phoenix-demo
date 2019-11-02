defmodule Assessment.Accounts.Credential do
  use Ecto.Schema
  import Ecto.Changeset
  alias Assessment.Accounts.Agent
  alias Comeonin.Bcrypt
  alias Ecto.Changeset


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
    |> hash_password()
  end

  defp hash_password(changeset) do
    case changeset do
      %Changeset{valid?: true, changes: %{password: password}} ->
        changeset
        |> Changeset.put_change(:password_digest, Bcrypt.hashpwsalt(password))
      _ ->
        changeset
    end
  end
end
