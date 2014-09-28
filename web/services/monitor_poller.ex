defmodule Service.MonitorPoller do

  def start_link do
    Agent.start_link(fn -> HashDict.new end)
  end

 
end