defmodule AssessmentWeb.Api.PatientController do
  use AssessmentWeb, :controller
  alias Assessment.Patients

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
