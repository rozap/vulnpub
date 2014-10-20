defmodule Vulnpub.Router do
  use Phoenix.Router

  plug Plug.Static, at: "/static", from: :vulnpub
  plug Plug.Stats
  
  get "/", Vulnpub.PageController, :index, as: :page
  get "/about/manifest", Vulnpub.PageController, :about_manifest, as: :page

  scope path: "/api" do
    scope path: "/v1" do
      resources "/users", Resources.User, only: [:create, :update, :show]
      resources "/monitors", Resources.Monitor, only: [:create, :destroy, :update, :show, :index]
      resources "/apikey", Resources.ApiKey, only: [:create, :destroy, :index, :show]
      resources "/vulns", Resources.Vuln, only: [:create, :show, :index]
      resources "/packages", Resources.Package, only: [:show, :index]
      resources "/alerts", Resources.Alert, only: [:index, :update]
      resources "/logs", Resources.Log, only: [:create]

    end
  end
end
