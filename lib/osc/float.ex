defimpl OSC.Encoder, for: Float do
  # TODO support 64 bit
  def encode(float, _) do
    << float :: big-float-size(32) >>
  end

  def flag(_), do: ?f
end
