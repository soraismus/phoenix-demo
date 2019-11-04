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

  def nilify_error({:ok, value}), do: value
  def nilify_error({:error, _}), do: nil

  def prohibit_nil(value), do: prohibit_nil(value, :invalid_nil)
  def prohibit_nil(nil, msg), do: {@error, msg}
  def prohibit_nil(value, _msg), do: {@ok, value}

  def to_integer(value) when is_binary(value) do
    try do
      {:ok, String.to_integer(value)}
    rescue
      ArgumentError -> {:error, :invalid_integer_format}
    end
  end
end
