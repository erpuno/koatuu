defmodule KOATUU.Mixfile do
  use Mix.Project
  def application(), do: [mod: {:koatuu, []}, applications: [:logger,:rocksdb,:kvs]]
  def deps() do
    [
      {:ex_doc, ">= 0.0.0", only: :dev},
      {:rocksdb, "~> 1.6.0"},
      {:jsone, "~> 1.5.1"},
      {:kvs, "~> 8.12.0"}
    ]
  end

  def project() do
    [
      app: :koatuu,
      version: "1.3.27",
      description: "KOATUU Ukrainian Classifier",
      package: package(),
      deps: deps()
    ]
  end

  def package do
    [
      files: ~w(priv include lib src mix.exs LICENSE),
      licenses: ["ISC"],
      name: :koatuu,
      maintainers: ["Namdak Tonpa"],
      links: %{"GitHub" => "https://github.com/erpuno/koatuu"}
    ]
  end
end
