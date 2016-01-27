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

  def parse_string(bin) do
    [string, rest] = :binary.split(bin, <<0>>)
    rest = string
    |> byte_size()
    |> size_to_padding()
    |> consume(rest)
    {string, rest}
  end

  def parse_blob(<< size :: big-size(32), blob :: binary-size(size), rest :: binary >>) do
    rest = size
    |> size_to_padding()
    |> +(1)
    |> consume(rest)
    {blob, rest}
  end

  defp size_to_padding(size) do
    case rem(size, 4) do
      0 -> 3
      1 -> 2
      2 -> 1
      3 -> 0
    end
  end

  defp consume(_, <<>>), do: <<>>
  defp consume(0, rest), do: rest
  for l <- 1..4 do
    defp consume(unquote(l), <<_ :: binary-size(unquote(l)), rest :: binary>>) do
      rest
    end
  end

  def values(data, acc \\ [], options)
  def values(<<>>, acc, _), do: :lists.reverse(acc)
  def values(<< size :: big-size(32), message :: binary-size(size), rest :: binary >>, acc, options) do
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
