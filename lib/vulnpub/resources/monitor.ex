
defmodule Resources.Monitor do
  require Resources.Resource
  use Resources.Resource, [exclude: []]


  def model do
    Models.Monitor
  end

end