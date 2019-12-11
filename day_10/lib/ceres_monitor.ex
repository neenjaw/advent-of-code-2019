defmodule CeresMonitor do
  def solve(map_as_string) do
    asteroid_map = AsteroidMap.parse_string_map(map_as_string)

    {:ok, {coord, m}} =
      asteroid_map.asteroids
      |> Task.async_stream(&AsteroidMap.generate_asteroid_visibility(&1, asteroid_map))
      |> Enum.to_list()
      |> Enum.max_by(fn {:ok, {_a, m}} -> map_size(m) end)

    {coord, map_size(m)}
  end

  def solve_2(coord, map_as_string) do
    asteroid_map = AsteroidMap.parse_string_map(map_as_string)

    visibility = AsteroidMap.generate_asteroid_visibility(coord, asteroid_map)

  end

end
