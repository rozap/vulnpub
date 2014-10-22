defmodule Service.Stats.CPU do
  use GenEvent

  def handle_event(:flush, parent) do
  end




  defmodule Stats do
    
    def start_link(options \\ []) do
      GenEvent.start_link Keyword.put_new(options, :name, __MODULE__)
    end
    
    def get_cpu_stats(_) do
      :cpu_sup.util |> Float.round
    end

    def build_message(value) do
      %{type: :cpu, data: %{utilization: value}}
    end
  end

end