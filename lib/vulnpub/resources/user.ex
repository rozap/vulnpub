
defmodule Resources.User do
  require Resources.Resource
	use Resources.Resource, [exclude: [:password]]


	def model do
		Models.User
	end

end