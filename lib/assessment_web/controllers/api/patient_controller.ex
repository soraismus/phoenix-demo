defmodule AssessmentWeb.Api.PatientController do
  use AssessmentWeb, :controller
  alias Assessment.Patients

  action_fallback(AssessmentWeb.Api.ErrorController)

  def create(conn, %{"patient" => params}) do
    with {:ok, patient} <- Patients.create_patient(params) do
      conn
      |> put_status(:created)
      |> render("create.json", patient: patient)
    end
  end

  def index(conn, _params) do
    patients = Patients.list_patients()
    conn |> render("index.json", patients: patients)
  end

  def show(conn, %{"id" => id}) do
    with {:ok, patient} <- Patients.get_patient(id) do
      conn
      |> render("show.json", patient: patient)
    end
  end
end
