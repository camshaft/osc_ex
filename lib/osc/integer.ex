defimpl OSC.Encoder, for: Integer do
  for {flag, size, limit} <- [{?i, 32, 2_147_483_647},
                              {?h, 64, 9_223_372_036_854_775_808}] do
    def encode(integer, _) when abs(integer) < unquote(limit) do
      << integer :: big-size(unquote(size)) >>
    end

    def flag(integer) when abs(integer) < unquote(limit) do
      unquote(flag)
    end
  end
end
