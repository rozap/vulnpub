use Mix.Config

# NOTE: To get SSL working, you will need to set:
#
#     ssl: true,
#     keyfile: System.get_env("SOME_APP_SSL_KEY_PATH"),
#     certfile: System.get_env("SOME_APP_SSL_CERT_PATH"),
#
# Where those two env variables point to a file on disk
# for the key and cert

config :phoenix, Vulnpub.Router,
  port: System.get_env("PORT"),
  ssl: false,
  host: "example.com",
  cookies: true,
  session_key: "_vulnpub_key",
  session_secret: "Q4QKS8!!TQ%9#V1+#(VSEIO95G(*%0K&S#LLB7L^&RV&QFY1(7NJ^Z71E%*PC5849#_1VD)PD4O"

config :logger, :console,
  level: :info,
  metadata: [:request_id]

