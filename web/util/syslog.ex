defmodule Vulnpub.Backends.Syslog do
  @moduledoc false

  use GenEvent
  require Phoenix.Config
  alias Phoenix.Config


  def init(_) do
    if user = Process.whereis(:user) do
      Process.group_leader(self(), user)
      {:ok, configure([])}
    else
      {:error, :ignore}
    end
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

    format = env
      |> Keyword.get(:format)
      |> Logger.Formatter.compile

    level    = Keyword.get(env, :level)
    metadata = Keyword.get(env, :metadata, [])
    location = Keyword.get(env, :location, "/var/log/vp.log")
    %{format: format, metadata: metadata, level: level, location: location}
  end

  defp log_event(level, msg, ts, md, state) do
    data = format_event(level, msg, ts, md, state)
    {:ok, file} = File.open(state.location, [:append])
    IO.write(file, data)
    File.close(file)
  end

  defp format_event(level, msg, ts, md, %{format: format, metadata: metadata}) do
    Logger.Formatter.format(format, level, msg, ts, Dict.take(md, metadata))
  end

end