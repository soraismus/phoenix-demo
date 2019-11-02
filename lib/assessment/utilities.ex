defmodule Assessment.Utilities do
  def map_error({:ok, value}, _fun), do: {:ok, value}
  def map_error({:error, value}, fun), do: {:error, fun.(value)}

  def map_value({:ok, value}, fun), do: {:ok, fun.(value)}
  def map_value({:error, value}, _fun), do: {:error, value}

  def prohibit_nil(:nil, msg), do: {:error, msg}
  def prohibit_nil(value, _msg), do: {:ok, value}
end
