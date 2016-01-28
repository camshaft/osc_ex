defmodule OSC.Message do
  defstruct address: "/",
            arguments: []

  def parse(message, options) do
    message
    |> OSC.Parser.parse_string()
    |> parse_body(options)
  end

  defp parse_body({address, "," <> _ = body}, options) do
    {flags_bin, rest} = OSC.Parser.parse_string(body)
    flags = parse_flags(flags_bin, [])
    arguments = parse_arguments(flags, rest, [])

    new(address, arguments, options)
  end
  defp parse_body({address, <<>>}, options) do
    new(address, [], options)
  end

  defp new(address, arguments, options) do
    %__MODULE__{address: address,
                arguments: arguments}
    |> OSC.Decoder.decode(options)
  end

  types = [{?i, :int32, quote(do: big-signed-integer-size(32))},
           {?f, :float, quote(do: big-signed-float-size(32))},
           {?s, :string},
           {?b, :blob},
           {?h, :int64, quote(do: big-signed-float-size(64))},
           {?t, :timetag},
           {?d, :double, quote(do: big-signed-float-size(64))},
           {?S, :atom},
           {?c, :char, quote(do: big-unsigned-size(32))},
           {?r, :rgba},
           {?m, :midi, quote(do: binary-size(4))},
           {?T, :true},
           {?F, :false},
           {?N, :nil},
           {?I, :impulse},
           {?[, :list_open},
           {?], :list_close}]

  defp parse_flags(<< ",", rest :: binary >>, flags) do
    parse_flags(rest, flags)
  end
  for {char, type, _} <- types do
    defp parse_flags(<< unquote(char), rest :: binary >>, flags) do
      parse_flags(rest, [unquote(type) | flags])
    end
  end
  for {char, type} <- types do
    defp parse_flags(<< unquote(char), rest :: binary >>, flags) do
      parse_flags(rest, [unquote(type) | flags])
    end
  end
  defp parse_flags(<<>>, flags) do
    :lists.reverse(flags)
  end

  defp parse_arguments([], <<>>, acc) do
    :lists.reverse(acc)
  end
  for {_, type, spec} <- types do
    defp parse_arguments([unquote(type) | flags], << int :: unquote(spec), rest :: binary>>, acc) do
      parse_arguments(flags, rest, [int | acc])
    end
  end
  for type <- [:true, :false, :nil] do
    defp parse_arguments([unquote(type) | flags], rest, acc) do
      parse_arguments(flags, rest, [unquote(type) | acc])
    end
  end
  defp parse_arguments([:blob | flags], bin, acc) do
    {blob, rest} = OSC.Parser.parse_blob(bin)
    parse_arguments(flags, rest, [blob | acc])
  end
  defp parse_arguments([:string | flags], bin, acc) do
    {string, rest} = OSC.Parser.parse_string(bin)
    parse_arguments(flags, rest, [string | acc])
  end
  defp parse_arguments([:atom | flags], bin, acc) do
    {string, rest} = OSC.Parser.parse_string(bin)
    parse_arguments(flags, rest, [String.to_atom(string) | acc])
  end
  defp parse_arguments([:list_open | flags], bin, acc) do
    {flags, bin, list} = parse_arguments(flags, bin, [])
    parse_arguments(flags, bin, [list | acc])
  end
  defp parse_arguments([:list_close | flags], bin, acc) do
    {flags, bin, :lists.reverse(acc)}
  end
end

defimpl OSC.Encoder, for: OSC.Message do
  def encode(value, options) do
    {flags, data} = Enum.reduce(value.arguments, {[?,], []}, fn(argument, {flags, data}) ->
      flag = OSC.Encoder.flag(argument)
      value = OSC.Encoder.encode(argument, options)
      {[flag | flags], [value | data]}
    end)

    [OSC.Encoder.BitString.encode(value.address, options),
     pad(flags),
     :lists.reverse(data)]
  end

  defp pad([]) do
    []
  end
  defp pad(flags) do
    flags
    |> :lists.reverse()
    |> OSC.Encoder.BitString.pad()
  end

  def flag(_), do: []
end
