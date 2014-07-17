defmodule Plug.Conn.Cookies do
  @moduledoc """
  Conveniences for encoding and decoding cookies
  """

  @doc """
  Decodes the given cookies as given in a request header.

  If a cookie is invalid, it is automatically
  discarded from the result.

  ## Examples

      iex> decode("key1=value1, key2=value2")
      %{"key1" => "value1", "key2" => "value2"}

  """
  def decode(cookie) do
    decode(:binary.split(cookie, [";", ","], [:global]), %{})
  end

  defp decode([], acc),
    do: acc
  defp decode([h|t], acc) do
    case decode_kv(h) do
      {k, v} -> decode(t, Map.put(acc, k, v))
      false  -> decode(t, acc)
    end
  end

  defp decode_kv(""),
    do: false
  defp decode_kv(<< ?$, _ :: binary >>),
    do: false
  defp decode_kv(<< h, t :: binary >>) when h in [?\s, ?\t],
    do: decode_kv(t)
  defp decode_kv(kv),
    do: decode_key(kv, "")

  defp decode_key("", _key),
    do: false
  defp decode_key(<< ?=, _ :: binary >>, ""),
    do: false
  defp decode_key(<< ?=, t :: binary >>, key),
    do: decode_value(t, "", key, "")
  defp decode_key(<< h, _ :: binary >>, _key) when h in [?\s, ?\t, ?\r, ?\n, ?\v, ?\f],
    do: false
  defp decode_key(<< h, t :: binary >>, key),
    do: decode_key(t, << key :: binary, h >>)

  defp decode_value("", _spaces, key, value),
    do: {key, value}
  defp decode_value(<< ?\s, t :: binary >>, spaces, key, value),
    do: decode_value(t, << spaces :: binary, ?\s >>, key, value)
  defp decode_value(<< h, _ :: binary >>, _spaces, _key, _value) when h in [?\t, ?\r, ?\n, ?\v, ?\f],
    do: false
  defp decode_value(<< h, t :: binary >>, spaces, key, value),
    do: decode_value(t, "", key, << value :: binary, spaces :: binary , h >>)

  @doc """
  Encodes the given cookies as expected in a response header.
  """
  def encode(key, opts \\ %{}) do
    header = "#{key}=#{opts[:value]}; path=#{opts[:path] || "/"}"

    if domain = opts[:domain] do
      header = header <> "; domain=#{domain}"
    end

    if max_age = opts[:max_age] do
      time = opts[:universal_time] || :calendar.universal_time
      time = add_seconds(time, max_age)
      header = header <> "; expires=" <> rfc2822(time) <> "; max-age=" <> Integer.to_string(max_age)
    end

    if opts[:secure] do
      header = header <> "; secure"
    end

    unless opts[:http_only] == false do
      header = header <> "; HttpOnly"
    end

    header
  end

  defp pad(number) when number in 0..9 do
    <<?0, ?0 + number>>
  end

  defp pad(number) do
    Integer.to_string(number)
  end

  defp rfc2822({{year, month, day} = date, {hour, minute, second}}) do
    weekday_name  = weekday_name(:calendar.day_of_the_week(date))
    month_name    = month_name(month)
    padded_day    = pad(day)
    padded_hour   = pad(hour)
    padded_minute = pad(minute)
    padded_second = pad(second)
    binary_year   = Integer.to_string(year)

    weekday_name <> ", " <> padded_day <>
      " " <> month_name <> " " <> binary_year <>
      " " <> padded_hour <> ":" <> padded_minute <>
      ":" <> padded_second <> " GMT"
  end

  defp weekday_name(1), do: "Mon"
  defp weekday_name(2), do: "Tue"
  defp weekday_name(3), do: "Wed"
  defp weekday_name(4), do: "Thu"
  defp weekday_name(5), do: "Fri"
  defp weekday_name(6), do: "Sat"
  defp weekday_name(7), do: "Sun"

  defp month_name(1),  do: "Jan"
  defp month_name(2),  do: "Feb"
  defp month_name(3),  do: "Mar"
  defp month_name(4),  do: "Apr"
  defp month_name(5),  do: "May"
  defp month_name(6),  do: "Jun"
  defp month_name(7),  do: "Jul"
  defp month_name(8),  do: "Aug"
  defp month_name(9),  do: "Sep"
  defp month_name(10), do: "Oct"
  defp month_name(11), do: "Nov"
  defp month_name(12), do: "Dec"

  defp add_seconds(time, seconds_to_add) do
    time_seconds = :calendar.datetime_to_gregorian_seconds(time)
    :calendar.gregorian_seconds_to_datetime(time_seconds + seconds_to_add)
  end
end
