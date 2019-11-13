defmodule AssessmentWeb.ControllerUtilities do
  @error :error
  @invalid_parameter :invalid_parameter
  @ok :ok

  def validate_id_type(value) do
    validate_parameter(value, "id", fn (x) -> is_integer(x) && x > 0 end)
  end

  def validate_parameter(value, parameter_name, predicate) do
    if predicate.(value) do
      {@ok, value}
    else
      {@error, {@invalid_parameter, parameter_name}}
    end
  end
end
