defmodule Vulnpub.Mixfile do
  use Mix.Project

  def project do
    [ app: :vulnpub,
      version: "0.0.1",
      elixir: "~> 0.14.2",
      deps: deps ]
  end

  # Configuration for the OTP application
  def application do
    [
      mod: { Vulnpub, [] },
      applications: [:phoenix, :postgrex, :ecto, :plug]
    ]
  end

  # Returns the list of dependencies in the format:
  # { :foobar, git: "https://github.com/elixir-lang/foobar.git", tag: "0.1" }
  #
  # To specify particular versions, regardless of the tag, do:
  # { :barbat, "~> 0.1", github: "elixir-lang/barbat" }
  defp deps do
    [
      {:phoenix, "0.3.0"},
      {:postgrex, ">= 0.0.0"},
      {:ecto, "0.2.4"},
      {:httpotion, github: "myfreeweb/httpotion"},
      {:jazz, github: "meh/jazz"},
      {:bcrypt, "0.5.0", github: "smarkets/erlang-bcrypt", compile: "make"}
    ]
  end
end
