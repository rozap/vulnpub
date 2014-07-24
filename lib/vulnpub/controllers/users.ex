defmodule Controllers.Users do
  use Phoenix.Controller
  require Controllers.Rest
  use Controllers.Rest, [resources: Resources.User]


end