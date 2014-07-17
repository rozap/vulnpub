defmodule Phoenix.Topic.Server do
  use GenServer
  alias Phoenix.Topic
  alias Phoenix.Topic.Server
  alias Phoenix.Topic.GarbageCollector

  defstruct role: :slave,
            gc_buffer: [],
            garbage_collect_after_ms: 60_000..300_000

  def start_link do
    :gen_server.start_link __MODULE__, [], []
  end

  def leader_pid, do: :global.whereis_name(__MODULE__)

  def init(_) do
    case :global.register_name(__MODULE__, self, &:global.notify_all_name/3) do
      :no  ->
        Process.link(leader_pid)
        {:ok, %Server{role: :slave}}
      :yes ->
        send(self, :garbage_collect_all)
        {:ok, %Server{role: :leader}}
    end
  end

  def handle_call(_message, _from, state = %Server{role: :slave}) do
    {:stop, :error, nil, state}
  end

  def handle_call({:exists?, group}, _from, state) do
    {:reply, exists?(group), state}
  end

  def handle_call({:active?, group}, _from, state) do
    {:reply, active?(group), state}
  end

  def handle_call({:create, group}, _from, state) do
    if exists?(group) do
      {:reply, :ok, state}
    else
      :ok = :pg2.create(group)
      {:reply, :ok, GarbageCollector.mark(state, group)}
    end
  end

  def handle_call({:subscribe, pid, group}, _from, state) do
    {:reply, :pg2.join(group, pid), state}
  end

  def handle_call({:unsubscribe, pid, group}, _from, state) do
    {:reply, :pg2.leave(group, pid), state}
  end

  def handle_call({:delete, group}, _from, state) do
    {:reply, delete(group), state}
  end

  def handle_info(_message, state = %Server{role: :slave}) do
    {:stop, :error, nil, state}
  end

  def handle_info({:garbage_collect, groups}, state) do
    active_groups = Enum.filter groups, fn group ->
      if active?(group) do
        true
      else
        delete(group)
        false
      end
    end

    {:noreply, GarbageCollector.mark(state, active_groups)}
  end

  def handle_info({:global_name_conflict, name, _other_pid}, state) do
    {:stop, {:global_name_conflict, name}, state}
  end

  def handle_info(:garbage_collect_all, state) do
    {:noreply, GarbageCollector.mark(state, Topic.list)}
  end

  defp exists?(group) do
    case :pg2.get_closest_pid(group) do
      pid when is_pid(pid)          -> true
      {:error, {:no_process, _}}    -> true
      {:error, {:no_such_group, _}} -> false
    end
  end

  defp active?(group) do
    case :pg2.get_closest_pid(group) do
      pid when is_pid(pid) -> true
      _ -> false
    end
  end

  defp delete(group), do: :pg2.delete(group)
end

