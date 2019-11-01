defmodule AssessmentWeb.PatientControllerTest do
  use AssessmentWeb.ConnCase

  alias Assessment.Patients

  @create_attrs %{address: "some address", name: "some name"}
  @update_attrs %{address: "some updated address", name: "some updated name"}
  @invalid_attrs %{address: nil, name: nil}

  def fixture(:patient) do
    {:ok, patient} = Patients.create_patient(@create_attrs)
    patient
  end

  describe "index" do
    test "lists all patients", %{conn: conn} do
      conn = get conn, patient_path(conn, :index)
      assert html_response(conn, 200) =~ "Listing Patients"
    end
  end

  describe "new patient" do
    test "renders form", %{conn: conn} do
      conn = get conn, patient_path(conn, :new)
      assert html_response(conn, 200) =~ "New Patient"
    end
  end

  describe "create patient" do
    test "redirects to show when data is valid", %{conn: conn} do
      conn = post conn, patient_path(conn, :create), patient: @create_attrs

      assert %{id: id} = redirected_params(conn)
      assert redirected_to(conn) == patient_path(conn, :show, id)

      conn = get conn, patient_path(conn, :show, id)
      assert html_response(conn, 200) =~ "Show Patient"
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post conn, patient_path(conn, :create), patient: @invalid_attrs
      assert html_response(conn, 200) =~ "New Patient"
    end
  end

  describe "edit patient" do
    setup [:create_patient]

    test "renders form for editing chosen patient", %{conn: conn, patient: patient} do
      conn = get conn, patient_path(conn, :edit, patient)
      assert html_response(conn, 200) =~ "Edit Patient"
    end
  end

  describe "update patient" do
    setup [:create_patient]

    test "redirects when data is valid", %{conn: conn, patient: patient} do
      conn = put conn, patient_path(conn, :update, patient), patient: @update_attrs
      assert redirected_to(conn) == patient_path(conn, :show, patient)

      conn = get conn, patient_path(conn, :show, patient)
      assert html_response(conn, 200) =~ "some updated address"
    end

    test "renders errors when data is invalid", %{conn: conn, patient: patient} do
      conn = put conn, patient_path(conn, :update, patient), patient: @invalid_attrs
      assert html_response(conn, 200) =~ "Edit Patient"
    end
  end

  describe "delete patient" do
    setup [:create_patient]

    test "deletes chosen patient", %{conn: conn, patient: patient} do
      conn = delete conn, patient_path(conn, :delete, patient)
      assert redirected_to(conn) == patient_path(conn, :index)
      assert_error_sent 404, fn ->
        get conn, patient_path(conn, :show, patient)
      end
    end
  end

  defp create_patient(_) do
    patient = fixture(:patient)
    {:ok, patient: patient}
  end
end
