defmodule OSC.TimeTag do
  defstruct time: 0

  def parse(<< time :: big-size(64) >>, options) do
    %__MODULE__{time: time}
    |> OSC.Decoder.decode(options)
  end
end

defimpl OSC.Encoder, for: OSC.TimeTag do
  def encode(%{time: time}, _), do: << time :: big-size(64) >>
  def flag(_), do: ?t
end
