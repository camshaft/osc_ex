defmodule OSC.EncodeError do
  defexception value: nil, message: nil

  def message(%{value: value, message: nil}) do
    "unable to encode value: #{inspect value}"
  end

  def message(%{message: message}) do
    message
  end
end

defprotocol OSC.Encoder do
  def encode(value, options)
  def flag(value)

  Kernel.def prefix_size(data, size \\ 64) do
    byte_size = :erlang.iolist_size(data)
    [<< byte_size :: big-size(size) >>, data]
  end
end
