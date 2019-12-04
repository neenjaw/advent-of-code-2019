defmodule Day03 do
  @moduledoc false

  def run_manhattan_distance(a, b) do
    path_a = compute_path_with_manhattan_distance(a)
    path_b = compute_path_with_manhattan_distance(b)

    find_closest_intersection_by_manhattan(path_a, path_b)
  end

  def compute_path_with_manhattan_distance(string_path) do
    Plotter.plot_route(string_path)
    |> Enum.map(fn coord -> {compute_manhattan_distance(coord), coord} end)
  end

  def compute_manhattan_distance({x, y}, {ox, oy} = _origin \\ {0, 0}) do
    x = x - ox
    x = if x >= 0, do: x, else: x * -1

    y = y - oy
    y = if y >= 0, do: y, else: y * -1

    x + y
  end

  def find_closest_intersection_by_manhattan(pa, pb) do
    by_distance = fn {d1, _}, {d2, _} -> d1 <= d2 end

    sa = MapSet.new(pa)
    sb = MapSet.new(pb)
    si = MapSet.intersection(sa, sb)

    si
    |> MapSet.to_list()
    |> Enum.sort(by_distance)
    |> case do
      [] -> nil
      [closest | _] -> closest
    end
  end

  def run_length(a,b) do
    path_a = Plotter.plot_route(a)
    steps_a = path_a |> Enum.with_index(1) |> Enum.into(%{})

    path_b = Plotter.plot_route(b)
    steps_b = path_b |> Enum.with_index(1) |> Enum.into(%{})

    sa = MapSet.new(path_a)
    sb = MapSet.new(path_b)
    si = MapSet.intersection(sa, sb)

    si
    |> MapSet.to_list()
    |> Enum.map(fn c -> {steps_a[c], steps_b[c]} end)
    |> Enum.map(fn {a, b} -> a + b end)
    |> Enum.min()
  end
end
