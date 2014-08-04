

defmodule Resources.Package do
  require Resources.Resource

  def model do
    Models.Package
  end
	use Resources.Resource, []
end