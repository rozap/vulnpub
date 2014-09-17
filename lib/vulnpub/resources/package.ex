

defmodule Resources.Package do
  use Finch.Resource, []

  def repo, do: Repo
  def model, do: Models.Package

end