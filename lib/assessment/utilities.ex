defmodule Assessment.Utilities do
  @ok :ok
  @error :error

  def bind_value({@ok, value}, fun), do: fun.(value)
  def bind_value({@error, value}, _fun), do: {@error, value}

  def bind_error({@ok, value}, _fun), do: {@ok, value}
  def bind_error({@error, value}, fun), do: fun.(value)

  def map_error({@ok, value}, _fun), do: {@ok, value}
  def map_error({@error, value}, fun), do: {@error, fun.(value)}

  def map_value({@ok, value}, fun), do: {@ok, fun.(value)}
  def map_value({@error, value}, _fun), do: {@error, value}

  def prohibit_nil(value), do: prohibit_nil(value, :invalid_nil)
  def prohibit_nil(nil, msg), do: {@error, msg}
  def prohibit_nil(value, _msg), do: {@ok, value}
end
