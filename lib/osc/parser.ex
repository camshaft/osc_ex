defmodule OSC.Parser do
  @type t :: OSC.Bundle.t | OSC.Message.t | OSC.Packet.t

  @spec parse(iodata, Keyword.t) :: {:ok, t} | {:error, :invalid}
    | {:error, {:invalid, String.t}}
  def parse(iodata, options \\ []) do
    string = IO.iodata_to_binary(iodata)
    case values(string, options) do
      [value] ->
        {:ok, OSC.Decoder.decode(%OSC.Packet{contents: value}, options)}
      [] ->
        {:ok, OSC.Decoder.decode(%OSC.Packet{}, options)}
    end
  catch
    :invalid ->
      {:error, :invalid}
    {:invalid, token} ->
      {:error, {:invalid, token}}
  end

  @spec parse!(iodata, Keyword.t) :: t
  def parse!(iodata, options \\ []) do
    case parse(iodata, options) do
      {:ok, value} ->
        value
      {:error, :invalid} ->
        raise SyntaxError
      {:error, {:invalid, token}} ->
        raise SyntaxError, token: token
    end
  end

  def values(data, acc \\ [], options)
  def values(<<>>, acc, _), do: :lists.reverse(acc)
  def values(<< size :: big-size(64), message :: binary-size(size), rest :: binary >>, acc, options) do
    acc = parse_message(message, acc, options)
    values(rest, acc, options)
  end
  def values(bin, acc, options) do
    acc = parse_message(bin, acc, options)
    values(<<>>, acc, options)
  end

  defp parse_message("", acc, _) do
    acc
  end
  defp parse_message("/" <> _ = message, acc, options) do
    [OSC.Message.parse(message, options) | acc]
  end
  defp parse_message("#bundle" <> _ = bundle, acc, options) do
    [OSC.Bundle.parse(bundle, options) | acc]
  end
end
