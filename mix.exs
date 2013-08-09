defmodule Tempfile.Mixfile do
  use Mix.Project

  def project do
    [ 
      app: :tempfile,
      version: "0.0.1",
      deps: deps,
      source_url: "https://github.com/glejeune/tempfile",
      name: "tempfile"
    ]
  end

  # Configuration for the OTP application
  def application do
    []
  end

  # Returns the list of dependencies in the format:
  # { :foobar, "0.1", git: "https://github.com/elixir-lang/foobar.git" }
  defp deps do
    [ 
      { :ex_doc, github: "elixir-lang/ex_doc" } 
    ]
  end
end
