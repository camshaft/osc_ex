defimpl OSC.Encoder, for: Atom do
  def encode(nil, _),   do: []
  def encode(true, _),  do: []
  def encode(false, _), do: []
  def encode(atom, options) do
    OSC.Encoder.BitString.encode(Atom.to_string(atom), options)
  end

  def flag(nil), do: ?N
  def flag(true), do: ?T
  def flag(false), do: ?F
  def flag(_), do: ?S
end
