defmodule Vulnpub.Router do
  use Phoenix.Router

  plug Plug.Static, at: "/static", from: :vulnpub
  get "/", Vulnpub.PageController, :index, as: :page
  get "/about/manifest", Vulnpub.PageController, :about_manifest, as: :page

  scope path: "/api" do
    scope path: "/v1" do
      resources "/users", Resources.User, except: []
      resources "/monitors", Resources.Monitor, except: []
      resources "/apikey", Resources.ApiKey, only: [:create, :destroy, :show]
      resources "/vulns", Resources.Vuln, only: [:create, :show, :index]
      resources "/packages", Resources.Package, only: [:show, :index]
      resources "/alerts", Resources.Alert, only: [:index, :update]

    end
  end
end
