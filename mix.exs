defmodule Core.MixProject do
  use Mix.Project

  def project do
    [
      app: :core,
      version: "1.0.0",
      elixir: "~> 1.14",
      elixirc_paths: elixirc_paths(Mix.env()),
      start_permanent: Mix.env() == :prod,
      aliases: aliases(),
      deps: deps(),
      dialyzer: [
        plt_add_apps: [:mix],
        plt_file: {:no_warn, "priv/plts/dialyzer.plt"}
      ]
    ]
  end

  # Configuration for the OTP application.
  #
  # Type `mix help compile.app` for more information.
  def application do
    [
      mod: {Core.Application, []},
      extra_applications: [:logger, :runtime_tools, :os_mon]
    ]
  end

  # Specifies which paths to compile per environment.
  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  # Specifies your project dependencies.
  #
  # Type `mix help deps` for examples and options.
  defp deps do
    [
      {:argon2_elixir, "~> 4.0"},
      {:phoenix, "~> 1.7", override: true},
      {:phoenix_ecto, "~> 4.4"},
      {:ecto_sql, "~> 3.10"},
      {:postgrex, "~> 0.17.1"},
      {:phoenix_html, "~> 3.3"},
      {:phoenix_live_reload, "~> 1.2", only: :dev},
      {:phoenix_live_view, "~> 0.20.0"},
      {:floki, "~> 0.35.2", only: :test},
      {:phoenix_live_dashboard, "~> 0.8.0"},
      {:esbuild, "~> 0.8.0", runtime: Mix.env() == :dev},
      {:tailwind, "~> 0.2.0", runtime: Mix.env() == :dev},
      {:swoosh, "~> 1.3"},
      {:finch, "~> 0.16.0"},
      {:telemetry_metrics, "~> 0.6.0"},
      {:telemetry_poller, "~> 1.0"},
      {:gettext, "~> 0.23.1"},
      {:jason, "~> 1.2"},
      {:plug_cowboy, "~> 2.5"},
      {:mimic, "~> 1.7", only: :test},
      {:cors_plug, "~> 3.0"},
      {:credo, "~> 1.4", only: :dev, runtime: false},
      {:dialyxir, "~> 1.0", only: :dev, runtime: false},
      {:ecto_psql_extras, "~> 0.7.0"},
      {:inflex, "~> 2.1"},
      {:earmark, "~> 1.4"},
      {:plug_telemetry_server_timing, "~> 0.3.0"},
      {:slugy, "~> 4.1"},
      {:hackney, "~> 1.18"},
      {:timex, "~> 3.7"},
      {:estate, "~> 1.0"},
      {:ex_doc, "~> 0.27", only: :dev, runtime: false},
      {:ueberauth, "~> 0.7"},
      {:ueberauth_twitch, "~> 0.1.0"},
      {:bandit, "~> 1.0"},
      {:ex_machina, "~> 2.7", only: :test},
      {:yaml_elixir, "~> 2.9"},
      {:ecto_function, "~> 1.0"},
      {:ecto_interface, "~> 1.0"},
      {:ex_heroicons, "~> 2.0"}
      # {:dep_from_hexpm, "~> 0.3.0"},
      # {:dep_from_git, git: "https://github.com/elixir-lang/my_dep.git", tag: "0.1.0"}
    ]
  end

  # Aliases are shortcuts or tasks specific to the current project.
  # For example, to install project dependencies and perform other setup tasks, run:
  #
  #     $ mix setup
  #
  # See the documentation for `Mix` for more info on aliases.
  defp aliases do
    [
      setup: ["deps.get", "ecto.setup", "assets.build"],
      "ecto.setup": ["ecto.create --quiet", "ecto.build"],
      "ecto.seeds": ["run priv/repo/seeds.exs --quiet"],
      "ecto.fixtures": ["run priv/repo/fixtures.exs --quiet"],
      "ecto.build": [
        "ecto.load --quiet",
        "ecto.migrate",
        "ecto.dump",
        "ecto.seeds",
        "ecto.fixtures"
      ],
      "ecto.reload": ["ecto.drop --quiet", "ecto.create --quiet", "ecto.build"],
      "ecto.reset": [
        "ecto.drop --quiet",
        "ecto.create --quiet",
        "ecto.migrate",
        "ecto.dump",
        "ecto.seeds",
        "ecto.fixtures"
      ],
      test: [
        "ecto.drop --quiet",
        "ecto.create --quiet",
        "ecto.load --quiet",
        "ecto.seeds",
        "test"
      ],
      "assets.setup": [
        "tailwind.install --if-missing",
        "esbuild.install --if-missing",
        "cmd --cd assets/ npm install"
      ],
      "assets.build": ["assets.setup", "tailwind default", "esbuild default"],
      "assets.deploy": ["tailwind default --minify", "esbuild default --minify", "phx.digest"],
      check: ["compile", "credo", "dialyzer --quiet"]
    ]
  end
end
