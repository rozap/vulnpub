defmodule Vulnpub.Views do

  defmacro __using__(_options) do
    quote do
      use Phoenix.View
      import unquote(__MODULE__)

      # This block is expanded within all views for aliases, imports, etc
      import Vulnpub.I18n
      import Vulnpub.Router.Helpers
    end
  end

  # Functions defined here are available to all other views/templates
end


