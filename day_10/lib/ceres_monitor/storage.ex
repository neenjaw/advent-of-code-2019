defmodule CeresMonitor.Storage do
  import AsteroidMap, only: [is_coordinate: 1, asteroid?: 1]

  alias AsteroidMap, as: AM

  def start(%AM{} = am) do
    Agent.start(fn -> am end)
  end

  def retrieve_map(pid) do
    Agent.get(pid, fn am -> am.map end)
  end

  def put_count(pid, coordinate, count) when is_coordinate(coordinate) do
    Agent.update(
      pid,
      fn am ->
        %{am | counts: Map.put(am.counts, coordinate, count)}
      end
    )
  end

  def destroy_asteroid(pid, coordinate) do
    Agent.get_and_update(pid, fn am ->
      if asteroid?(am.map[coordinate]) do
        destroy_count = if am.meta[:destroy_count], do: am.meta.destroy_count, else: 0
        destroy_record = if am.meta[:destroy_record], do: am.meta.destroy_record, else: %{}

        meta =
          am.meta
          |> Map.put(:destroy_count, destroy_count + 1)
          |> Map.put(:destroy_record, Map.put(destroy_record, destroy_count + 1, coordinate))

        {:ok, %{am | map: Map.put(am.map, coordinate, "*"), meta: meta}}
      else
        {:noop, am}
      end
    end)
  end

  def stop(pid) do
    data = Agent.get(pid, fn am -> am end)
    Agent.stop(pid)
    data
  end
end
