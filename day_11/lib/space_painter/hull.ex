defmodule SpacePainter.Hull do
  defstruct panels: %{}, count: 0

  alias SpacePainter.Hull

  @opaque hull::pid

  def init(options \\ []) do
    start_color = options[:start_on]

    Agent.start_link(fn -> %Hull{panels: %{{0,0} => {start_color, :unvisited}}} end)
  end

  def paint(hull, position, color) do
    Agent.update(hull, fn state ->
      panel = Map.get(state.panels, position)
      count = if panel == nil or elem(panel, 1) == :unvisited, do: state.count + 1, else: state.count

      %{state | panels: Map.put(state.panels, position, {color, :visited}), count: count}
    end)
  end

  def camera(hull, position) do
    Agent.get(hull, fn state ->
      panel = Map.get(state.panels, position)

      if panel == nil do
        0
      else
        panel |> elem(0)
      end
    end)
  end

  def get_hull(hull) do
    Agent.get(hull, fn state -> state end)
  end

  def stop(hull) do
    state = Agent.get(hull, fn state -> state end)
    Agent.stop(hull)
    state
  end
end
