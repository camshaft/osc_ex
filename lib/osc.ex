defmodule OSC do
  alias OSC.Encoder
  alias OSC.Parser

  @doc """
  Encode a value to OSC.
      iex> OSC.encode(%OSC.Message{address: "/foo", arguments: ["hello"]})
      {:ok, <<47, 102, 111, 111, 0, 0, 0, 0, 44, 115, 0, 0, 104, 101, 108, 108, 111, 0, 0, 0>>}
  """
  @spec encode(Encoder.t, Keyword.t) :: {:ok, iodata} | {:ok, String.t}
    | {:error, {:invalid, any}}
  def encode(value, options \\ []) do
    {:ok, encode!(value, options)}
  rescue
    exception in [OSC.EncodeError] ->
      {:error, {:invalid, exception.value}}
  end

  @doc """
  Encode a value to OSC as iodata.
      iex> OSC.encode(%OSC.Message{address: "/foo", arguments: ["hello"]})
      {:ok, [["/foo", 0, 0, 0, 0], [',s', 0, 0], [["hello", 0, 0, 0]]]}
  """
  @spec encode_to_iodata(Encoder.t, Keyword.t) :: {:ok, iodata}
    | {:error, {:invalid, any}}
  def encode_to_iodata(value, options \\ []) do
    encode(value, [iodata: true] ++ options)
  end

  @doc """
  Encode a value to OSC, raises an exception on error.
      iex> OSC.encode!(%OSC.Message{address: "/foo", arguments: ["hello"]})
      <<47, 102, 111, 111, 0, 0, 0, 0, 44, 115, 0, 0, 104, 101, 108, 108, 111, 0, 0, 0>>
  """
  @spec encode!(Encoder.t, Keyword.t) :: iodata | no_return
  def encode!(value, options \\ []) do
    iodata = Encoder.encode(value, options)
    unless options[:iodata] do
      iodata |> IO.iodata_to_binary
    else
      iodata
    end
  end

  @doc """
  Encode a value to OSC as iodata, raises an exception on error.
      iex> OSC.encode_to_iodata!(%OSC.Message{address: "/foo", arguments: ["hello"]})
      [["/foo", 0, 0, 0, 0], [',s', 0, 0], [["hello", 0, 0, 0]]]
  """
  @spec encode_to_iodata!(Encoder.t, Keyword.t) :: iodata | no_return
  def encode_to_iodata!(value, options \\ []) do
    encode!(value, [iodata: true] ++ options)
  end

  @doc """
  Decode OSC to a value.
      iex> OSC.decode(<<47, 102, 111, 111, 0, 0, 0, 0, 44, 115, 0, 0, 104, 101, 108, 108, 111, 0, 0, 0>>)
      {:ok, %OSC.Message{address: "/foo", arguments: ["hello"]}}
  """
  @spec decode(iodata, Keyword.t) :: {:ok, Parser.t} | {:error, :invalid}
    | {:error, {:invalid, String.t}}
  def decode(iodata, options \\ []) do
    Parser.parse(iodata, options)
  end

  @doc """
  Decode OSC to a value, raises an exception on error.
      iex> OSC.decode!(<<47, 102, 111, 111, 0, 0, 0, 0, 44, 115, 0, 0, 104, 101, 108, 108, 111, 0, 0, 0>>)
      %OSC.Message{address: "/foo", arguments: ["hello"]}
  """
  @spec decode!(iodata, Keyword.t) :: Parser.t | no_return
  def decode!(iodata, options \\ []) do
    Parser.parse!(iodata, options)
  end
end
