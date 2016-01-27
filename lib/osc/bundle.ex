defmodule OSC.Bundle do
  defstruct time: %OSC.TimeTag{},
            elements: []

  def parse(<< "#bundle", 0, time :: binary-size(8), rest :: binary >>, options) do
    %__MODULE__{time: OSC.TimeTag.parse(time, options),
                elements: OSC.Parser.values(rest, options)}
    |> OSC.Decoder.decode(options)
  end
end

defimpl OSC.Encoder, for: OSC.Bundle do
  def encode(%{time: time, elements: elements}, options) do
    ["#bundle", 0,
     OSC.Encoder.encode(time, options),
     encode_elements(elements, options)]
  end

  defp encode_elements(elements, options) do
    for element <- elements do
      element
      |> OSC.Encoder.encode(options)
      |> OSC.Encoder.prefix_size()
    end
  end

  def flag(_), do: []
end
