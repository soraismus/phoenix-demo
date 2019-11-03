defmodule Assessment.Sessions do
  @moduledoc """
  The Sessions context.
  """

  alias Assessment.Accounts.{Agent,Credential}

  def session_changeset(params) do
    %Agent{}
    |> Agent.changeset(params)
    |> Ecto.Changeset.cast_assoc(:credential, with: &Credential.validate/2)
  end
end
