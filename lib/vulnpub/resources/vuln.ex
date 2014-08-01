
defmodule Resources.Vuln.Validator do
  use Resources.ModelValidator, [only: [:create, :update]]
end


defmodule Resources.Vuln.Authenticator do
  use Resources.Authenticator, []
end



defmodule Resources.Vuln do
  require Resources.Resource

  def model do
    Models.Vuln
  end

	use Resources.Resource, [
    middleware: [
      Resources.Vuln.Authenticator,
      Resources.Vuln.Validator
    ]
  ]
end