defmodule Test.OSC do
  use OSC.TestCase, async: false
  use ExCheck

  defp string do
    33..111
    |> Enum.reject(fn(c) ->
      c in [35, 42, 44, 63, 91, 93, 123, 125]
    end)
    |> oneof()
    |> list()
    |> bind(&to_string/1)
  end

  defp address do
    bind string, fn(s) ->
      "/#{s}"
    end
  end

  defp arguments do
    [
      smaller(delay(arguments)),
      atom,
      int32,
      int64,
      bool,
      binary,
      string,
      nil
    ]
    |> oneof()
    |> list()
  end

  defp int64 do
    int()
  end

  defp int32 do
    int()
  end

  defp timetag do
    bind {pos_integer, pos_integer}, fn({seconds, fraction}) ->
      %OSC.TimeTag{seconds: seconds, fraction: fraction}
    end
  end

  defp message do
    bind {address, arguments}, fn({address, arguments}) ->
      %OSC.Message{address: address, arguments: arguments}
    end
  end

  defp bundle do
    bind {timetag, smaller(list(delay(content)), 4)}, fn({timetag, elements}) ->
      %OSC.Bundle{time: timetag, elements: elements}
    end
  end

  defp content do
    oneof([
      bundle,
      message,
      # nil
    ])
  end

  defp packet do
    bind content, fn(contents) ->
      %OSC.Packet{contents: contents}
    end
  end

  property :osc do
    for_all packet in packet do
      round_trip(packet)
    end
  end
end
