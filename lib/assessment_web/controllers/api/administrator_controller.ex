defmodule AssessmentWeb.Api.AdministratorController do
  use AssessmentWeb, :controller

  import AssessmentWeb.Api.ControllerUtilities,
    only: [ authentication_error: 1,
            authorization_error: 1,
            changeset_error: 2,
            id_type_validation_error: 1,
            internal_error: 2,
            match_error: 2,
            resource_error: 4
          ]
  import AssessmentWeb.ControllerUtilities, only: [validate_id_type: 1]
  import AssessmentWeb.GuardianController, only: [authenticate_administrator: 1]

  alias Assessment.Accounts

  @created :created
  @error :error
  @invalid_parameter :invalid_parameter
  @no_resource :no_resource
  @not_authenticated :not_authenticated
  @not_authorized :not_authorized
  @not_found :not_found
  @ok :ok

  def create(conn, %{"administrator" => params}) do
    params =
      %{}
      |> Map.put("username", Map.get(params, "username"))
      |> Map.put("credential", Map.take(params, ["password"]))
      |> Map.put("administrator", Map.take(params, ["email"]))
    with {@ok, _} <- authenticate_administrator(conn),
         {@ok, agent} <- Accounts.create_administrator(params) do
      conn
      |> put_status(@created)
      |> render("create.json", administrator: agent.administrator)
    else
      {@error, @not_authenticated} ->
        conn
        |> authentication_error()
      {@error, @not_authorized} ->
        conn
        |> authorization_error()
      {@error, %Ecto.Changeset{} = changeset} ->
        conn
        |> changeset_error(changeset)
      _ ->
        conn
        |> internal_error("ADCR-A")
    end
  end
  def create(conn, _) do
    conn
    |> match_error("to create an administrator")
  end

  def index(conn, _params) do
    case authenticate_administrator(conn) do
      {@ok, _} ->
        conn
        |> render("index.json", administrators: Accounts.list_administrators())
      {@error, @not_authenticated} ->
        conn
        |> authentication_error()
      {@error, @not_authorized} ->
        conn
        |> authorization_error()
      _ ->
        conn
        |> internal_error("ADIN-A")
    end
  end

  def show(conn, %{"id" => id}) do
    with {@ok, _} <- validate_id_type(id),
         {@ok, _} <- authenticate_administrator(conn),
         {@ok, administrator} <- Accounts.get_administrator(id) do
      conn
      |> render("show.json", administrator: administrator)
    else
      {@error, {@invalid_parameter, _}} ->
        conn
        |> id_type_validation_error()
      {@error, @not_authenticated} ->
        conn
        |> authentication_error()
      {@error, @not_authorized} ->
        conn
        |> authorization_error()
      {@error, @no_resource} ->
        conn
        |> resource_error("administrator ##{id}", "does not exist", @not_found)
      _ ->
        conn
        |> internal_error("ADSH-A-1")
    end
  end
  def show(conn, _), do: conn |> internal_error("ADSH-A-2")
end
