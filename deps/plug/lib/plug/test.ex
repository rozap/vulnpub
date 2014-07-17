defmodule Plug.Test do
  @moduledoc """
  Conveniences for testing plugs

  ## Examples

  This module can be used in your test cases:

      use ExUnit.Case, async: true
      use Plug.Test

  and it will:

      * import all functions from this module
      * import all functions from `Plug.Conn`
      * alias `Plug.Conn` to `Conn`

  """

  @doc false
  defmacro __using__(_) do
    quote do
      import Plug.Test
      import Plug.Conn
      alias  Plug.Conn
    end
  end

  alias Plug.Conn

  @doc """
  Creates a test connection.

  The request `method` and `path` must be given as required
  arguments. `method` may be any value that implements `to_string/1`
  and it will properly converted and normalized.

  The `params_or_body` field must be one of:

  * `nil` - meaning there is no body;
  * a binary - containing a request body. For such cases, `:headers`
    must be given as option with a content-type;
  * a map or list - containing the parameters which will automatically
    set the content-type to multipart. The map or list may be contain
    other lists or maps and all entries keywords and maps will be
    normalized to string keys;

  The only option supported so far is `:headers` which expects a
  list of headers.
  """
  @spec conn(String.Chars.t, binary, binary | list | map | nil, [headers: Conn.headers]) :: Conn.t
  def conn(method, path, params_or_body \\ nil, opts \\ []) do
    Plug.Adapters.Test.Conn.conn(method, path, params_or_body, opts)
  end

  @doc """
  Puts a new request header.
  Previous entries of the same headers are removed.
  """
  @spec put_req_header(Conn.t, binary, binary) :: Conn.t
  def put_req_header(%Conn{req_headers: headers} = conn, key, value) when is_binary(key) and is_binary(value) do
    %{conn | req_headers: :lists.keystore(key, 1, headers, {key, value})}
  end

  @doc """
  Deletes a request header.
  """
  @spec delete_req_header(Conn.t, binary) :: Conn.t
  def delete_req_header(%Conn{req_headers: headers} = conn, key) when is_binary(key) do
    %{conn | req_headers: :lists.keydelete(key, 1, headers)}
  end

  @doc """
  Puts a request cookie.
  """
  @spec put_req_cookie(Conn.t, binary, binary) :: Conn.t
  def put_req_cookie(conn, key, value) when is_binary(key) and is_binary(value) do
    conn = delete_req_cookie(conn, key)
    %{conn | req_headers: [{"cookie", "#{key}=#{value}"}|conn.req_headers]}
  end

  @doc """
  Deletes a request cookie.
  """
  @spec delete_req_cookie(Conn.t, binary) :: Conn.t
  def delete_req_cookie(%Conn{req_cookies: %Plug.Conn.Unfetched{}} = conn, key) when is_binary(key) do
    key  = "#{key}="
    size = byte_size(key)
    fun  = &match?({"cookie", value} when binary_part(value, 0, size) == key, &1)
    %{conn | req_headers: Enum.reject(conn.req_headers, fun)}
  end

  def delete_req_cookie(_conn, key) when is_binary(key) do
    raise ArgumentError, message: "cannot put/delete request cookies after cookies were fetched"
  end
end
