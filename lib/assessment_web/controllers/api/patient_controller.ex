defmodule AssessmentWeb.Api.PatientController do
  use AssessmentWeb, :controller
  import AssessmentWeb.Api.ControllerUtilities,
    only: [changeset_error: 3, internal_error: 1, resource_error: 3]
  alias Assessment.Patients

  def create(conn, %{"patient" => params}) do
    case Patients.create_patient(params) do
      {:ok, patient} ->
        conn
        |> put_status(:created)
        |> render("create.json", patient: patient)
      {:error, %Ecto.Changeset{} = changeset} ->
        conn
        |> changeset_error(changeset)
      _ ->
        conn
        |> internal_error("PACR")
    end
  end

  def index(conn, _params) do
    conn
    |> render("index.json", patients: Patients.list_patients())
  end

  def show(conn, %{"id" => id}) do
    case Patients.get_patient(id) do
      {:ok, patient} ->
        conn
        |> render("show.json", patient: patient)
      {:error, :no_resource} ->
        conn
        |> resource_error("patient ##{id}", "does not exist", :not_found)
      _ ->
        conn
        |> internal_error("PASH")
    end
  end
end
