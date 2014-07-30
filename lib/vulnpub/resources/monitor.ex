


defmodule Resources.Monitor do
  require Resources.Resource
  


  def model do
    Models.Monitor
  end

	use Resources.Resource, [
    exclude: [], 
    middleware: []
  ]
end