defmodule AssessmentWeb.Api.PatientView do
  use AssessmentWeb, :view
  alias Assessment.Patients.Patient
  alias Assessment.Utilities
  alias Assessment.Utilities.ToJson

  def render("index.json", %{patients: patients}) do
    %{
      count: length(patients),
      patients: ToJson.to_json(patients),
    }
  end

  def render("show.json", %{patient: patient}) do
    %{patient: ToJson.to_json(patient)}
  end

  defimpl ToJson, for: Patient do
    def to_json(%Patient{} = patient) do
      patient
      |> Utilities.to_json([:id, :name, :address])
    end
  end
end
