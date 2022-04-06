defmodule KOATUU.Mixfile do
  use Mix.Project

  def application(),
    do: [
      mod: {:koatuu, []},
      applications: [:rocksdb, :kvs],
      extra_applications: [:logger]
    ]

  def deps() do
    [
      {:ex_doc, "~> 0.19", only: :dev, override: true},
      {:rocksdb, "~> 1.6.0"},
      {:jsone, "~> 1.5.1"},
      {:kvs, "~> 9.4.1"}
    ]
  end

  def project() do
    [
      app: :koatuu,
      version: "1.4.0",
      description: "KOATUU Ukrainian Classifier",
      package: package(),
      deps: deps()
    ]
  end

  def package do
    [
      files: ~w(priv include src mix.exs LICENSE),
      licenses: ["ISC"],
      maintainers: ["Namdak Tonpa"],
      links: %{"GitHub" => "https://github.com/erpuno/koatuu"}
    ]
  end
end
