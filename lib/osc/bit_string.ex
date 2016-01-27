defimpl OSC.Encoder, for: BitString do
  def encode(value, options) do
    String.printable?(value)
    && encode_string(value, options)
    || encode_blob(value, options)
  end

  defp encode_string(value, _) do
    pad(value)
  end

  defp encode_blob(value, _) do
    value
    |> OSC.Encoder.prefix_size(32)
    |> pad()
  end

  def pad(value) do
    case rem(:erlang.iolist_size(value), 4) do
      0 -> [value,0,0,0,0]
      1 -> [value,0,0,0]
      2 -> [value,0,0]
      3 -> [value,0]
    end
  end

  def flag(value) do
    String.printable?(value) && ?s || ?b
  end
end
