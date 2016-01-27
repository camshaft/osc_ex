defmodule OSC.Packet do
  defstruct contents: nil
end

defimpl OSC.Encoder, for: OSC.Packet do
  def encode(%{contents: nil}, _) do
    <<>>
  end
  def encode(%{contents: contents}, options) do
    encoded = OSC.Encoder.encode(contents, options)
    case options[:transport] do
      :tcp ->
        OSC.Encoder.prefix_size(encoded, 64)
      _ ->
        encoded
    end
  end

  def flag(_), do: []
end
