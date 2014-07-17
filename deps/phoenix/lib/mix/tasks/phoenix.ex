defmodule Mix.Tasks.Phoenix do
  use Mix.Task

  @shortdoc "List Phoenix tasks"

  @moduledoc """
  List Phoenix tasks with help
  """
  def run([]) do
    help
  end

  def run(["--help"]) do
    help
  end

  defp help do
    Mix.shell.info """
    Help:

    mix phoenix.new     app_name destination_path  # Creates new Phoenix application
    mix phoenix.routes  [MyApp.Router]             # Prints routes
    mix phoenix.start   [MyApp.Router]             # Starts worker
    mix phoenix --help                             # This help
    """
  end
end
