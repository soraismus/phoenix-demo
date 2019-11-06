defmodule AssessmentWeb.Api.PatientController do
  use AssessmentWeb, :controller
  import AssessmentWeb.Api.ControllerUtilities,
    only: [ authentication_error: 1,
            authorization_error: 1,
            changeset_error: 2,
            internal_error: 2,
            resource_error: 4
          ]
  import AssessmentWeb.GuardianController, only: [authenticate_administrator: 1]
  alias Assessment.Patients

  def create(conn, %{"patient" => params}) do
    with {:ok, _} <- authenticate_administrator(conn),
         {:ok, patient} <- Patients.create_patient(params) do
      conn
      |> put_status(:created)
      |> render("create.json", patient: patient)
    else
      {:error, :not_authenticated} ->
        conn
        |> authentication_error()
      {:error, :not_authorized} ->
        conn
        |> authorization_error()
      {:error, %Ecto.Changeset{} = changeset} ->
        conn
        |> changeset_error(changeset)
      _ ->
        conn
        |> internal_error("PACR")
    end
  end

  def index(conn, _params) do
    case authenticate_administrator(conn) do
      {:ok, _} ->
        conn
        |> render("index.json", patients: Patients.list_patients())
      {:error, :not_authenticated} ->
        conn
        |> authentication_error()
      {:error, :not_authorized} ->
        conn
        |> authorization_error()
      _ ->
        conn
        |> internal_error("PAIN")
    end
  end

  def show(conn, %{"id" => id}) do
    with {:ok, _} <- authenticate_administrator(conn),
         {:ok, patient} <- Patients.get_patient(id) do
      conn
      |> render("show.json", patient: patient)
    else
      {:error, :not_authenticated} ->
        conn
        |> authentication_error()
      {:error, :not_authorized} ->
        conn
        |> authorization_error()
      {:error, :no_resource} ->
        conn
        |> resource_error("patient ##{id}", "does not exist", :not_found)
      _ ->
        conn
        |> internal_error("PASH")
    end
  end
end
