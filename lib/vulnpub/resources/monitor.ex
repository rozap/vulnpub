
defmodule Resources.Monitor.Validator do
  use Resources.ModelValidator, [only: [:create, :update]]
end


defmodule Resources.Monitor.Authenticator do
  use Resources.Authenticator, []
end


defmodule Resources.Monitor do
  require Resources.Resource
  


  def model do
    Models.Monitor
  end

	use Resources.Resource, [
    exclude: [], 
    middleware: [
      Resources.Monitor.Authenticator,
      Resources.Monitor.Validator
    ]
  ]
end