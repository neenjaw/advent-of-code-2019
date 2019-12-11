defmodule CeresMonitor do
  def solve(map_as_string) do
    asteroid_map = AsteroidMap.parse_string_map(map_as_string)

    {:ok, {coord, m}} =
      asteroid_map.asteroids
      |> Task.async_stream(&AsteroidMap.generate_asteroid_visibility(&1, asteroid_map))
      |> Enum.max_by(fn {:ok, {_a, m}} -> map_size(m) end)

    {coord, map_size(m)}
  end

  def solve_2(coord, map_as_string) do
    asteroid_map = AsteroidMap.parse_string_map(map_as_string)

    {_coord, asteroids_grouped_by_angle} =
      coord
      |> AsteroidMap.generate_asteroid_visibility(asteroid_map)

    asteroids_grouped_by_angle
    |> Enum.sort_by(fn {a, _} -> a end, &<=/2)
    |> Enum.map(fn {_, asteroids} ->
      asteroids
      |> Enum.sort_by(fn {_, d} -> d end, &<=/2)
      |> Enum.map(&elem(&1,0))
    end)
    |> reduce_firing_order()
  end

  def reduce_firing_order(asteroids), do: do_reduce_firing_order(asteroids, 1, [], [])

  def do_reduce_firing_order([], _, [], destroyed), do: destroyed |> Enum.into(%{})

  def do_reduce_firing_order([], count, stack, destroyed) do
    next_round = stack |> Enum.reverse()
    do_reduce_firing_order(next_round, count, [], destroyed)
  end

  def do_reduce_firing_order([shot | next_shots], count, stack, destroyed) do
    [first | rest] = shot
    destroyed = [{count, first} | destroyed]
    count = count + 1

    if rest == [] do
      do_reduce_firing_order(next_shots, count, stack, destroyed)
    else
      do_reduce_firing_order(next_shots, count, [rest | stack], destroyed)
    end
  end
end
