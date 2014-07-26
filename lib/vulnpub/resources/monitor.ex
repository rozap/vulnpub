
defmodule Resources.Monitor.Validator do
  use Resources.ModelValidator
end


defmodule Resources.Monitor do
  require Resources.Resource
  


  def model do
    Models.Monitor
  end

	use Resources.Resource, [
    exclude: [], 
    middleware: [
      Resources.Monitor.Validator, 
    ]
  ]
end