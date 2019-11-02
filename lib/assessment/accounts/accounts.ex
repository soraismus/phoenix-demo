defmodule Assessment.Accounts do
  @moduledoc """
  The Accounts context.
  """

  import Ecto.Query, warn: false

  alias Assessment.{Repo,Utilities}
  alias Assessment.Accounts.{Agent,Administrator,Courier,Pharmacy}

  @no_resource :no_resource

  @doc """
  Returns the list of agents.

  ## Examples

      iex> list_agents()
      [%Agent{}, ...]

  """
  def list_agents do
    Repo.all(Agent)
  end

  @doc """
  Gets a single agent.

  ## Examples

      iex> get_agent(123)
      {:ok, %Agent{}}

      iex> get_agent(456)
      {:error, :no_resource}

  """
  def get_agent(id) do
    Agent
    |> Repo.get(id)
    |> Utilities.prohibit_nil(@no_resource)
  end

  @doc """
  Creates a agent.

  ## Examples

      iex> create_agent(%{field: value})
      {:ok, %Agent{}}

      iex> create_agent(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_agent(attrs \\ %{}) do
    %Agent{}
    |> Agent.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Deletes a Agent.

  ## Examples

      iex> delete_agent(agent)
      {:ok, %Agent{}}

      iex> delete_agent(agent)
      {:error, %Ecto.Changeset{}}

  """
  def delete_agent(%Agent{} = agent) do
    Repo.delete(agent)
  end

  defp set_username(%{agent: %{username: username}, username: _} = account)
    when is_binary(username) do
      %{account | username: username}
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking agent changes.

  ## Examples

      iex> change_agent(agent)
      %Ecto.Changeset{source: %Agent{}}

  """
  def change_agent(%Agent{} = agent) do
    Agent.changeset(agent, %{})
  end

  @doc """
  Returns the list of administrators.

  ## Examples

      iex> list_administrators()
      [%Administrator{}, ...]

  """
  def list_administrators do
    Administrator
    |> Repo.all()
    |> Repo.preload(:agent)
    |> Enum.map(&set_username/1)
  end

  @doc """
  Gets a single administrator.

  ## Examples

      iex> get_administrator(123)
      {:ok, %Administrator{}}

      iex> get_administrator(456)
      {:error, :no_resource}

  """
  def get_administrator(id) do
    Administrator
    |> Repo.get(id)
    |> Repo.preload(:agent)
    |> set_username()
    |> Utilities.prohibit_nil(@no_resource)
  end

  @doc """
  Creates a administrator.

  ## Examples

      iex> create_administrator(%{field: value})
      {:ok, %Administrator{}}

      iex> create_administrator(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_administrator(attrs \\ %{}) do
    #%Agent{}
    #|> Agent.changeset(attrs)
    #|> Ecto.Changeset.cast_assoc(:administrator, with: &Administrator.changeset/2)
    #|> Repo.insert()

    #Ecto.Multi.new()
    #|> Ecto.Multi.run(:agent, fn (_) -> create_agent(attrs) end)
    #|> Ecto.Multi.run(
    #      :administrator,
    #      fn (%{agent: agent}) ->
    #          new_attrs =
    #            attrs
    #            |> Map.put(:agent_id, agent.id)
    #            |> Map.delete(:username)
    #          %Agent{}
    #          |> Agent.changeset(new_attrs)
    #          |> Repo.insert()
    #      end)
    #|> Repo.transaction()

    %Administrator{}
    |> Administrator.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Deletes a Administrator.

  ## Examples

      iex> delete_administrator(administrator)
      {:ok, %Administrator{}}

      iex> delete_administrator(administrator)
      {:error, %Ecto.Changeset{}}

  """
  def delete_administrator(%Administrator{} = administrator) do
    Repo.delete(administrator)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking administrator changes.

  ## Examples

      iex> change_administrator(administrator)
      %Ecto.Changeset{source: %Administrator{}}

  """
  def change_administrator(%Administrator{} = administrator) do
    Administrator.changeset(administrator, %{})
  end

  @doc """
  Returns the list of pharmacies.

  ## Examples

      iex> list_pharmacies()
      [%Pharmacy{}, ...]

  """
  def list_pharmacies do
    Pharmacy
    |> Repo.all()
    |> Repo.preload(:agent)
    |> Enum.map(&set_username/1)
  end

  @doc """
  Gets a single pharmacy.

  ## Examples

      iex> get_pharmacy(123)
      {:ok, %Pharmacy{}}

      iex> get_pharmacy(456)
      {:error, :no_resource}

  """
  def get_pharmacy(id) do
    Pharmacy
    |> Repo.get(id)
    |> Repo.preload(:agent)
    |> set_username()
    |> Utilities.prohibit_nil(@no_resource)
  end

  @doc """
  Creates a pharmacy.

  ## Examples

      iex> create_pharmacy(%{field: value})
      {:ok, %Pharmacy{}}

      iex> create_pharmacy(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_pharmacy(attrs \\ %{}) do
    %Agent{}
    |> Agent.changeset(attrs)
    |> Ecto.Changeset.cast_assoc(:pharmacy, with: &Pharmacy.changeset/2)
    |> Repo.insert()
  end

  @doc """
  Deletes a Pharmacy.

  ## Examples

      iex> delete_pharmacy(pharmacy)
      {:ok, %Pharmacy{}}

      iex> delete_pharmacy(pharmacy)
      {:error, %Ecto.Changeset{}}

  """
  def delete_pharmacy(%Pharmacy{} = pharmacy) do
    Repo.delete(pharmacy)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking pharmacy changes.

  ## Examples

      iex> change_pharmacy(pharmacy)
      %Ecto.Changeset{source: %Pharmacy{}}

  """
  def change_pharmacy(%Pharmacy{} = pharmacy) do
    Pharmacy.changeset(pharmacy, %{})
  end

  @doc """
  Returns the list of couriers.

  ## Examples

      iex> list_couriers()
      [%Courier{}, ...]

  """
  def list_couriers do
    Courier
    |> Repo.all()
    |> Repo.preload(:agent)
    |> Enum.map(&set_username/1)
  end

  @doc """
  Gets a single courier.

  ## Examples

      iex> get_courier(123)
      {:ok, %Courier{}}

      iex> get_courier(456)
      {:error, :no_resource}

  """
  def get_courier(id) do
    Courier
    |> Repo.get(id)
    |> Repo.preload(:agent)
    |> set_username()
    |> Utilities.prohibit_nil(@no_resource)
  end

  @doc """
  Creates a courier.

  ## Examples

      iex> create_courier(%{field: value})
      {:ok, %Courier{}}

      iex> create_courier(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_courier(attrs \\ %{}) do
    %Agent{}
    |> Agent.changeset(attrs)
    |> Ecto.Changeset.cast_assoc(:courier, with: &Courier.changeset/2)
    |> Repo.insert()
  end

  @doc """
  Deletes a Courier.

  ## Examples

      iex> delete_courier(courier)
      {:ok, %Courier{}}

      iex> delete_courier(courier)
      {:error, %Ecto.Changeset{}}

  """
  def delete_courier(%Courier{} = courier) do
    Repo.delete(courier)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking courier changes.

  ## Examples

      iex> change_courier(courier)
      %Ecto.Changeset{source: %Courier{}}

  """
  def change_courier(%Courier{} = courier) do
    Courier.changeset(courier, %{})
  end
end
