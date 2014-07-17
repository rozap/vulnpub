defmodule Vulnpub.Router do
  use Phoenix.Router

  plug Plug.Static, at: "/static", from: :vulnpub
  get "/", Vulnpub.Controllers.Pages, :index, as: :page

  scope path: "api" do
    scope path: "v1" do
      resources "users", Controllers.Users, only: [:index, :show, :create]
    end
  end
end
