# This file is responsible for configuring your application
use Mix.Config

# Note this file is loaded before any dependency and is restricted
# to this project. If another project depends on this project, this
# file won't be loaded nor affect the parent project.

config :phoenix, Vulnpub.Router,
  port: System.get_env("PORT"),
  ssl: false,
  static_assets: true,
  cookies: true,
  session_key: "_vulnpub_key",
  session_secret: "Q4QKS8!!TQ%9#V1+#(VSEIO95G(*%0K&S#LLB7L^&RV&QFY1(7NJ^Z71E%*PC5849#_1VD)PD4O",
  catch_errors: true,
  debug_errors: false,
  error_controller: Vulnpub.PageController

config :phoenix, :code_reloader,
  enabled: false

config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Import environment specific config. Note, this must remain at the bottom of
# this file to properly merge your previous config entries.
import_config "#{Mix.env}.exs"
