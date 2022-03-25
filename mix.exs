defmodule KOATUU.Mixfile do
  use Mix.Project
  def deps(), do: [{:ex_doc, ">= 0.0.0", only: :dev}]
  def application(), do: [mod: {:koatuu, []}, applications: []]

  def project() do
    [
      app: :koatuu,
      version: "0.11.0",
      description: "KOATUU Ukrainian Classifier",
      package: package(),
      deps: deps()
    ]
  end

  def package do
    [
      files: ~w(priv lib src mix.exs LICENSE),
      licenses: ["ISC"],
      name: :koatuu,
      maintainers: ["Namdak Tonpa"],
      links: %{"GitHub" => "https://github.com/erpuno/koatuu"}
    ]
  end
end
