defimpl OSC.Encoder, for: List do
  def encode(list, options) do
    Enum.map(list, &OSC.Encoder.encode(&1, options))
  end

  def flag(value) do
    [?[, Enum.map(value, &OSC.Encoder.flag/1), ?]]
  end
end
