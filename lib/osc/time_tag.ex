defmodule OSC.TimeTag do
  defstruct seconds: 0,
            fraction: 0

  def parse(<< seconds :: big-size(32), fraction :: big-size(32) >>, options) do
    %__MODULE__{seconds: seconds, fraction: fraction}
    |> OSC.Decoder.decode(options)
  end
end

defimpl OSC.Encoder, for: OSC.TimeTag do
  def encode(%{seconds: seconds, fraction: fraction}, _) do
    << seconds :: big-size(32), fraction :: big-size(32) >>
  end
  def flag(_), do: ?t
end
