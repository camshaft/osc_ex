defmodule OSC.TestCase do
  defmacro __using__(opts) do
    quote do
      use ExUnit.Case, unquote(opts)
      import unquote(__MODULE__)
    end
  end
  use ExCheck

  def round_trip(data) do
    data
    |> OSC.encode_to_iodata!()
    |> OSC.decode!()
    |> assert_equal(data)
  end

  defmacro delay(x) do
    quote do
      fn ->
        unquote(x)
      end
    end
  end

  def smaller(domain, factor \\ 2) do
    sized fn(size) ->
      resize(:random.uniform((div(size, factor))+1), domain)
    end
  end

  def larger(domain, factor \\ 2) do
    sized fn(size) ->
      resize(:random.uniform(size * factor), domain)
    end
  end

  def assert_equal(actual, expected) do
    value = assert_equal_item(actual, expected)
    if !value do
      IO.inspect {actual, expected}
    end
    value
  catch
    :not_equal ->
      false
  end

  defp assert_equal_item(actual, expected) when is_float(actual) do
    abs(actual - expected) < 0.1
  end
  defp assert_equal_item(actual, expected) when is_map(actual) do
    assert_map_keys(actual) != assert_map_keys(expected) && throw(:not_equal)

    actual
    |> Map.delete(:__struct__)
    |> Enum.all?(fn({key, value}) ->
      assert_equal_item(value, Map.get(expected, key))
    end)
  end
  defp assert_equal_item(actual, expected) when is_list(actual) do
    length(actual) != length(expected) && throw(:not_equal)

    Enum.zip(actual, expected)
    |> Enum.all?(fn({a, e}) ->
      assert_equal_item(a, e)
    end)
  end
  defp assert_equal_item(actual, expected) do
    actual == expected
  end

  defp assert_map_keys(map) do
    map
    |> Map.keys()
    |> Enum.sort()
  end
end

ExCheck.start()
ExUnit.start()
