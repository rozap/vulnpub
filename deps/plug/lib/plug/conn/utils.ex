defmodule Plug.Conn.Utils do
  @moduledoc """
  Utilities for working with connection data
  """

  @type params :: [{binary, binary}]

  @upper ?A..?Z
  @lower ?a..?z
  @alpha ?0..?9
  @other [?., ?-, ?+]
  @space [?\s, ?\t]
  @specials [?(, ?), ?<, ?>, ?@, ?,, ?;, ?:, ?\\, ?", ?/, ?[, ?], ??, ?., ?=]

  @doc ~S"""
  Parses the request content type header.

  Type and subtype are case insensitive while the
  sensitiveness of params depends on its key and
  therefore are not handled by this parser.

  ## Examples

      iex> content_type "text/plain"
      {:ok, "text", "plain", %{}}

      iex> content_type "APPLICATION/vnd.ms-data+XML"
      {:ok, "application", "vnd.ms-data+xml", %{}}

      iex> content_type "x-sample/json; charset=utf-8"
      {:ok, "x-sample", "json", %{"charset" => "utf-8"}}

      iex> content_type "x-sample/json  ; charset=utf-8  ; foo=bar"
      {:ok, "x-sample", "json", %{"charset" => "utf-8", "foo" => "bar"}}

      iex> content_type "\r\n text/plain;\r\n charset=utf-8\r\n"
      {:ok, "text", "plain", %{"charset" => "utf-8"}}

      iex> content_type "x y"
      :error

      iex> content_type "/"
      :error

      iex> content_type "x/y z"
      :error

  """
  @spec content_type(binary) :: {:ok, type :: binary, subtype :: binary, params} | :error
  def content_type(binary) do
    ct_first(strip_spaces(binary), "")
  end

  defp ct_first(<< ?/, t :: binary >>, acc) when acc != "",
    do: ct_second(t, "", acc)
  defp ct_first(<< h, t :: binary >>, acc) when h in @upper,
    do: ct_first(t, << acc :: binary, h + 32 >>)
  defp ct_first(<< h, t :: binary >>, acc) when h in @lower or h in @alpha or h == ?-,
    do: ct_first(t, << acc :: binary, h >>)
  defp ct_first(_, _acc),
    do: :error

  defp ct_second(<< h, t :: binary >>, acc, first) when h in @upper,
    do: ct_second(t, << acc :: binary, h + 32 >>, first)
  defp ct_second(<< h, t :: binary >>, acc, first) when h in @lower or h in @alpha or h in @other,
    do: ct_second(t, << acc :: binary, h >>, first)
  defp ct_second(t, acc, first),
    do: ct_params(t, first, acc)

  defp ct_params(t, first, second) do
    case strip_spaces(t) do
      ""       -> {:ok, first, second, %{}}
      ";" <> t -> {:ok, first, second, params(t)}
      _        -> :error
    end
  end

  @doc """
  Parses headers parameters.

  Keys are case insensitive and downcased,
  invalid key-value pairs are discarded.

  ## Examples

      iex> params("foo=bar")
      %{"foo" => "bar"}

      iex> params("  foo=bar  ")
      %{"foo" => "bar"}

      iex> params("FOO=bar")
      %{"foo" => "bar"}

      iex> params("foo=BAR ; wat")
      %{"foo" => "BAR"}

      iex> params("=")
      %{}

  """
  @spec params(binary) :: params
  def params(t) do
    params(:binary.split(t, ";", [:global]), %{})
  end

  defp params([], acc),
    do: acc
  defp params([h|t], acc) do
    case params_key(strip_spaces(h), "") do
      {k, v} -> params(t, Map.put(acc, k, v))
      false  -> params(t, acc)
    end
  end

  defp params_key(<< ?=, t :: binary >>, acc) when acc != "",
    do: params_value(t, acc)
  defp params_key(<< h, _ :: binary >>, _acc) when h in @specials or h in @space or h < 32 or h === 127,
    do: false
  defp params_key(<< h, t :: binary >>, acc) when h in @upper,
    do: params_key(t, << acc :: binary, h + 32 >>)
  defp params_key(<< h, t :: binary >>, acc),
    do: params_key(t, << acc :: binary, h >>)
  defp params_key(<<>>, _acc),
    do: false

  defp params_value(token, key) do
    case token(token) do
      false -> false
      value -> {key, value}
    end
  end

  @doc ~S"""
  Parses a value as defined in [RFC-1341](1).
  For convenience, trims whitespace at the end of the token.
  Returns false is the token is invalid.

  [1]: http://www.w3.org/Protocols/rfc1341/4_Content-Type.html

  ## Examples

      iex> token("foo")
      "foo"

      iex> token("foo-bar")
      "foo-bar"

      iex> token("<foo>")
      false

      iex> token(~s["<foo>"])
      "<foo>"

      iex> token(~S["<f\oo>\"<b\ar>"])
      "<foo>\"<bar>"

      iex> token("foo  ")
      "foo"

      iex> token("foo bar")
      false

  """
  @spec token(binary) :: binary | false
  def token(""),
    do: false
  def token(<< ?", quoted :: binary >>),
    do: quoted_token(quoted, "")
  def token(token),
    do: unquoted_token(token, "")

  defp quoted_token(<<>>, _acc),
    do: false
  defp quoted_token(<< ?", t :: binary >>, acc),
    do: strip_spaces(t) == "" and acc
  defp quoted_token(<< ?\\, h, t :: binary >>, acc),
    do: quoted_token(t, << acc :: binary, h >>)
  defp quoted_token(<< h, t :: binary >>, acc),
    do: quoted_token(t, << acc :: binary, h >>)

  defp unquoted_token("\r\n" <> t, acc),
    do: strip_spaces(t) == "" and acc
  defp unquoted_token(<< h, t :: binary >>, acc) when h in @space,
    do: strip_spaces(t) == "" and acc
  defp unquoted_token(<< h, _ :: binary >>, _acc) when h in @specials or h < 32 or h === 127,
    do: false
  defp unquoted_token(<< h, t :: binary >>, acc),
    do: unquoted_token(t, << acc :: binary, h >>)
  defp unquoted_token(<< >>, acc),
    do: acc

  @doc """
  Parses a comma-separated header list.

  ## Examples

      iex> list("foo, bar")
      ["foo", "bar"]

      iex> list("foobar")
      ["foobar"]

      iex> list("")
      []

      iex> list("empties, , are,, filtered")
      ["empties", "are", "filtered"]
  """
  @spec list(binary) :: [binary]
  def list(binary) do
    elems = :binary.split(binary, ",", [:global])
    Enum.reduce(elems, [], fn elem, acc ->
      elem = strip_spaces(elem)
      if elem != "", do: [elem|acc], else: acc
    end) |> Enum.reverse
  end

  defp strip_spaces("\r\n" <> t),
    do: strip_spaces(t)
  defp strip_spaces(<<h, t :: binary>>) when h in [?\s, ?\t],
    do: strip_spaces(t)
  defp strip_spaces(t),
    do: t
end
