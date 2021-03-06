defmodule Vulnpub.Mixfile do
  use Mix.Project

  def project do
    [ app: :vulnpub,
      version: "0.0.1",
      elixir: "~> 1.0.0",
      elixirc_paths: ["lib", "web"],
      deps: deps ]
  end

  # Configuration for the OTP application
  def application do
    [
      mod: { Vulnpub, [] },
      applications: [
        :crypto, 
        :bcrypt, 
        :phoenix, 
        :cowboy, 
        :logger, 
        :postgrex, 
        :ecto, 
        :plug, 
        :os_mon
      ]
    ]
  end

  # Returns the list of dependencies in the format:
  # { :foobar, git: "https://github.com/elixir-lang/foobar.git", tag: "0.1" }
  #
  # To specify particular versions, regardless of the tag, do:
  # { :barbat, "~> 0.1", github: "elixir-lang/barbat" }
  defp deps do
    [
      {:phoenix, "0.4.1"},
      {:cowboy, "~> 1.0.0"},
      {:plug, "0.7.0"},
      {:postgrex, "0.6.0"},
      {:ecto, "0.2.4"},
      {:httpotion, github: "myfreeweb/httpotion"},
      {:jazz, github: "meh/jazz"},
      {:decimal, "~> 0.2.4" },
      {:bcrypt, "0.5.0", github: "smarkets/erlang-bcrypt", compile: "make"},
      {:finch, "0.0.3"}
    ]
  end
end
