
defmodule Resources.User do
  require Resources.Resource

  def model do
    Models.User
  end

  use Resources.Resource, [
  	exclude: [:password], 
  	middleware: [
  		Resources.ModelValidator, 
  		Resources.ModelAuthorizor
  	]
  ]
end