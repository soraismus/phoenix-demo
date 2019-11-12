defmodule AssessmentWeb.Browser.PatientController do
  use AssessmentWeb, :controller

  import AssessmentWeb.Browser.ControllerUtilities,
    only: [ internal_error: 2,
            resource_error: 3,
          ]

  alias Assessment.Patients
  alias Assessment.Patients.Patient

  plug :authenticate_administrator

  @error :error
  @ignore :ignore
  @index :index
  @info :info
  @new :new
  @no_resource :no_resource
  @ok :ok
  @request_path :request_path
  @show :show

  def index(conn, _params) do
    conn
    |> render("index.html", patients: Patients.list_patients())
  end

  def new(conn, _params) do
    conn
    |> render("new.html", changeset: Patients.change_patient(%Patient{}))
  end

  def create(conn, %{"patient" => patient_params}) do
    case Patients.create_patient(patient_params) do
      {@ok, patient} ->
        conn
        |> put_flash(@info, "Patient created successfully.")
        |> redirect(to: patient_path(conn, @show, patient))
      {@error, %Ecto.Changeset{} = changeset} ->
        conn
        |> put_status(400)
        |> render("new.html", changeset: changeset)
      _ ->
        conn
        |> internal_error("PACR_B")
    end
  end

  def show(conn, %{"id" => id}) do
    with {@ok, patient} <- Patients.get_patient(id) do
      conn
      |> render("show.html", patient: patient)
    else
      {@error, @no_resource} ->
        conn
        |> resource_error("patient ##{id}", "does not exist")
      _ ->
        conn
        |> internal_error("PASH_B")
    end
  end

  def delete(conn, %{"id" => id}) do
    with {@ok, patient} <- Patients.get_patient(id),
         {@ok, _patient} = Patients.delete_patient(patient) do
      conn
      |> put_flash(@info, "Patient deleted successfully.")
      |> redirect(to: patient_path(conn, @index))
    else
      {@error, @no_resource} ->
        conn
        |> resource_error("patient ##{id}", "does not exist")
      _ ->
        conn
        |> internal_error("PADE_B")
    end
  end

  defp authenticate_administrator(conn, _) do
    agent = conn.assigns.agent
    if agent && agent.account_type == "administrator" do
      conn
    else
      conn
      |> put_flash(@error, "You must be logged in as an administrator to manage patients.")
      |> put_session(@request_path, @ignore)
      |> redirect(to: session_path(conn, @new))
      |> halt()
    end
  end
end
