defmodule Osc.Mixfile do
  use Mix.Project

  def project do
    [app: :osc,
     version: "0.1.0",
     elixir: "~> 1.0",
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     deps: deps]
  end

  def application do
    [applications: [:logger]]
  end

  defp deps do
    [{:excheck, "~> 0.3.2", only: [:dev, :test]},
     {:triq, github: "krestenkrab/triq", only: [:dev, :test]}]
  end
end
