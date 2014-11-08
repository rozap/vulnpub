defmodule Logger.Backends.Syslog do
  @moduledoc false

  use GenEvent
  require Phoenix.Config
  alias Phoenix.Config


  def init(_) do
    {:ok, :syslog}
  end

  def handle_call({:configure, options}, _state) do
    {:ok, :ok, configure(options)}
  end

  def handle_event({_level, gl, _event}, state) when node(gl) != node() do
    {:ok, state}
  end

  def handle_event({level, _gl, {Logger, msg, ts, md}}, %{level: min_level} = state) do
    if is_nil(min_level) or Logger.compare_levels(level, min_level) != :lt do
      log_event(level, msg, ts, md, state)
    end
    {:ok, state}
  end

  ## Helpers

  defp configure(options) do
    env = Application.get_env(:logger, :syslog, [])
    console = configure_merge(env, options)
    Application.put_env(:logger, :syslog, console)

    format = console
      |> Keyword.get(:format)
      |> Logger.Formatter.compile

    level    = Keyword.get(console, :level)
    metadata = Keyword.get(console, :metadata, [])
    colors   = configure_colors(console)
    %{format: format, metadata: metadata, level: level, colors: colors}
  end

  defp configure_merge(env, options) do
    Keyword.merge(env, options, fn
      :colors, v1, v2 -> Keyword.merge(v1, v2)
      _, _v1, v2 -> v2
    end)
  end

  defp configure_colors(console) do
    colors  = Keyword.get(console, :colors, [])
    debug   = Keyword.get(colors, :debug, :cyan)
    info    = Keyword.get(colors, :info, :normal)
    warn    = Keyword.get(colors, :warn, :yellow)
    error   = Keyword.get(colors, :error, :red)
    enabled = Keyword.get(colors, :enabled, IO.ANSI.enabled?)
    %{debug: debug, info: info, warn: warn, error: error, enabled: enabled}
  end

  defp log_event(level, msg, ts, md, %{colors: colors} = state) do
    data = format_event(level, msg, ts, md, state)
    {:ok, file} = File.open(Config.get([:vulnpub])[:log_location], [:append])
    IO.write(file, data)
    File.close(file)
  end

  defp format_event(level, msg, ts, md, %{format: format, metadata: metadata}) do
    Logger.Formatter.format(format, level, msg, ts, Dict.take(md, metadata))
  end

end