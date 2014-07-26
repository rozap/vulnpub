
defmodule Resources.User do
  require Resources.Resource

  


  def model do
    Models.User
  end

  use Resources.Resource, [exclude: [:password]]
end