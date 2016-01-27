defprotocol OSC.Decoder do
  @fallback_to_any true

  def decode(value, options)
end

defimpl OSC.Decoder, for: Any do
  def decode(value, _options) do
    value
  end
end
