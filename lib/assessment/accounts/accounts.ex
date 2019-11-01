defmodule Assessment.Accounts do
  @moduledoc """
  The Accounts context.
  """

  import Ecto.Query, warn: false
  alias Assessment.Repo

  alias Assessment.Accounts.Agent

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

  Raises `Ecto.NoResultsError` if the Agent does not exist.

  ## Examples

      iex> get_agent!(123)
      %Agent{}

      iex> get_agent!(456)
      ** (Ecto.NoResultsError)

  """
  def get_agent!(id), do: Repo.get!(Agent, id)

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
  Updates a agent.

  ## Examples

      iex> update_agent(agent, %{field: new_value})
      {:ok, %Agent{}}

      iex> update_agent(agent, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_agent(%Agent{} = agent, attrs) do
    agent
    |> Agent.changeset(attrs)
    |> Repo.update()
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

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking agent changes.

  ## Examples

      iex> change_agent(agent)
      %Ecto.Changeset{source: %Agent{}}

  """
  def change_agent(%Agent{} = agent) do
    Agent.changeset(agent, %{})
  end

  alias Assessment.Accounts.Administrator

  @doc """
  Returns the list of administrators.

  ## Examples

      iex> list_administrators()
      [%Administrator{}, ...]

  """
  def list_administrators do
    Repo.all(Administrator)
  end

  @doc """
  Gets a single administrator.

  Raises `Ecto.NoResultsError` if the Administrator does not exist.

  ## Examples

      iex> get_administrator!(123)
      %Administrator{}

      iex> get_administrator!(456)
      ** (Ecto.NoResultsError)

  """
  def get_administrator!(id), do: Repo.get!(Administrator, id)

  @doc """
  Creates a administrator.

  ## Examples

      iex> create_administrator(%{field: value})
      {:ok, %Administrator{}}

      iex> create_administrator(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_administrator(attrs \\ %{}) do
    %Administrator{}
    |> Administrator.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a administrator.

  ## Examples

      iex> update_administrator(administrator, %{field: new_value})
      {:ok, %Administrator{}}

      iex> update_administrator(administrator, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_administrator(%Administrator{} = administrator, attrs) do
    administrator
    |> Administrator.changeset(attrs)
    |> Repo.update()
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

  alias Assessment.Accounts.Pharmacy

  @doc """
  Returns the list of pharmacies.

  ## Examples

      iex> list_pharmacies()
      [%Pharmacy{}, ...]

  """
  def list_pharmacies do
    Repo.all(Pharmacy)
  end

  @doc """
  Gets a single pharmacy.

  Raises `Ecto.NoResultsError` if the Pharmacy does not exist.

  ## Examples

      iex> get_pharmacy!(123)
      %Pharmacy{}

      iex> get_pharmacy!(456)
      ** (Ecto.NoResultsError)

  """
  def get_pharmacy!(id), do: Repo.get!(Pharmacy, id)

  @doc """
  Creates a pharmacy.

  ## Examples

      iex> create_pharmacy(%{field: value})
      {:ok, %Pharmacy{}}

      iex> create_pharmacy(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_pharmacy(attrs \\ %{}) do
    %Pharmacy{}
    |> Pharmacy.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a pharmacy.

  ## Examples

      iex> update_pharmacy(pharmacy, %{field: new_value})
      {:ok, %Pharmacy{}}

      iex> update_pharmacy(pharmacy, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_pharmacy(%Pharmacy{} = pharmacy, attrs) do
    pharmacy
    |> Pharmacy.changeset(attrs)
    |> Repo.update()
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

  alias Assessment.Accounts.Courier

  @doc """
  Returns the list of couriers.

  ## Examples

      iex> list_couriers()
      [%Courier{}, ...]

  """
  def list_couriers do
    Repo.all(Courier)
  end

  @doc """
  Gets a single courier.

  Raises `Ecto.NoResultsError` if the Courier does not exist.

  ## Examples

      iex> get_courier!(123)
      %Courier{}

      iex> get_courier!(456)
      ** (Ecto.NoResultsError)

  """
  def get_courier!(id), do: Repo.get!(Courier, id)

  @doc """
  Creates a courier.

  ## Examples

      iex> create_courier(%{field: value})
      {:ok, %Courier{}}

      iex> create_courier(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_courier(attrs \\ %{}) do
    %Courier{}
    |> Courier.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a courier.

  ## Examples

      iex> update_courier(courier, %{field: new_value})
      {:ok, %Courier{}}

      iex> update_courier(courier, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_courier(%Courier{} = courier, attrs) do
    courier
    |> Courier.changeset(attrs)
    |> Repo.update()
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
