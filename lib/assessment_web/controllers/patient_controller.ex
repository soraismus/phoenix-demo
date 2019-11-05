defmodule AssessmentWeb.PatientController do
  use AssessmentWeb, :controller

  alias Assessment.Patients
  alias Assessment.Patients.Patient

  plug :authenticate_administrator

  def index(conn, _params) do
    patients = Patients.list_patients()
    render(conn, "index.html", patients: patients)
  end

  def new(conn, _params) do
    changeset = Patients.change_patient(%Patient{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"patient" => patient_params}) do
    case Patients.create_patient(patient_params) do
      {:ok, patient} ->
        conn
        |> put_flash(:info, "Patient created successfully.")
        |> redirect(to: patient_path(conn, :show, patient))
      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    patient = Patients.get_patient!(id)
    render(conn, "show.html", patient: patient)
  end

  def delete(conn, %{"id" => id}) do
    patient = Patients.get_patient!(id)
    {:ok, _patient} = Patients.delete_patient(patient)

    conn
    |> put_flash(:info, "Patient deleted successfully.")
    |> redirect(to: patient_path(conn, :index))
  end

  defp authenticate_administrator(conn, _) do
    agent = conn.assigns.agent
    if agent && agent.account_type == "administrator" do
      conn
    else
      conn
      |> put_flash(:error, "You must be logged in as an administrator to manage patients.")
      |> put_session(:request_path, conn.request_path)
      |> redirect(to: session_path(conn, :new))
      |> halt()
    end
  end
end
