use Mix.Config

config :phoenix, Vulnpub.Router,
  port: System.get_env("PORT") || 4001,
  ssl: false,
  cookies: true,
  session_key: "_vulnpub_key",
  session_secret: "Q4QKS8!!TQ%9#V1+#(VSEIO95G(*%0K&S#LLB7L^&RV&QFY1(7NJ^Z71E%*PC5849#_1VD)PD4O"

config :phoenix, :code_reloader,
  enabled: true

config :logger, :console,
  level: :debug


