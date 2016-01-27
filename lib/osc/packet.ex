defmodule OSC.Packet do
  defstruct contents: nil
end

defimpl OSC.Encoder, for: OSC.Packet do
  def encode(%{contents: nil}, _) do
    <<>>
  end
  def encode(%{contents: contents}, options) do
    contents
    |> OSC.Encoder.encode(options)
    |> OSC.Encoder.prefix_size()
  end

  def flag(_), do: []
end
