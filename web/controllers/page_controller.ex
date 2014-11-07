defmodule Vulnpub.PageController do
  use Phoenix.Controller

  def index(conn, _params) do
    render conn, "index"
  end

  def about_manifest(conn, _params) do
    render conn, "about_manifest"
  end

  def about(conn, _params) do
    render conn, "about"
  end

  def not_found(conn, _params) do
    render conn, "not_found"
  end

  def error(conn, _params) do
    render conn, "error"
  end
end
