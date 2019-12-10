defmodule CeresMonitor do
  import AsteroidMap, only: [asteroid?: 1, station?: 1, is_coordinate: 1]

  alias CeresMonitor.Storage

  def solve(map_as_string) do
    asteroid_map = AsteroidMap.parse_string_map(map_as_string)

    {:ok, storage} = Storage.start(asteroid_map)

    asteroid_map.map
    |> Map.to_list()
    |> Stream.filter(fn {_, e} -> AsteroidMap.asteroid?(e) end)
    |> Stream.map(fn {c, _} -> c end)
    |> Task.async_stream(&count_visible(asteroid_map, &1, storage))
    |> Stream.run()

    Storage.stop(storage).counts |> Map.to_list() |> Enum.max_by(fn {_, n} -> n end)
  end

  def count_visible(%AsteroidMap{} = asteroid_map, coordinate, storage) do
    %{slopes: slopes, y_range: y_range, x_range: x_range} = asteroid_map.meta

    count =
      slopes
      |> Enum.reduce(0, fn slope, sum ->
        if asteroid_along_slope?(asteroid_map.map, coordinate, slope, x_range, y_range) do
          sum + 1
        else
          sum
        end
      end)

    Storage.put_count(storage, coordinate, count)
  end

  def asteroid_along_slope?(map, coordinate, slope, x_range, y_range) do
    coordinate
    |> apply_slope(slope)
    |> Stream.iterate(&apply_slope(&1, slope))
    |> Stream.map(fn {x, y} = coordinate ->
      cond do
        x not in x_range -> :out_of_range
        y not in y_range -> :out_of_range
        map[coordinate] |> asteroid?() -> :found
        true -> :nothing_found
      end
    end)
    |> Stream.drop_while(fn
      :nothing_found -> true
      _ -> false
    end)
    |> Enum.take(1)
    |> hd()
    |> case do
      :out_of_range -> false
      :found -> true
    end
  end

  def apply_slope({x, y}, {sx, sy}), do: {x + sx, y + sy}

  def destroy_asteroids(map_as_string, coordinate) when is_coordinate(coordinate) do
    asteroid_map =
      map_as_string
      |> AsteroidMap.parse_string_map()
      |> AsteroidMap.generate_ordered_slope_mutations()

    cond do
      asteroid?(asteroid_map.map[coordinate]) -> do_destroy_asteroids(asteroid_map, coordinate)
      station?(asteroid_map.map[coordinate]) -> do_destroy_asteroids(asteroid_map, coordinate)
      true -> {:error, "not an asteroid to mount laser"}
    end
  end

  def do_destroy_asteroids(asteroid_map, coordinate) do
    {:ok, storage} = CeresMonitor.Storage.start(asteroid_map)

    {:ok, coord_storage} =
      Agent.start(fn ->
        asteroid_map.meta.ordered_slopes
        |> Enum.map(fn s -> {s, coordinate} end)
        |> Enum.into(%{})
      end)

    asteroid_map.meta.ordered_slopes
    |> Stream.cycle()
    |> Stream.each(fn slope ->
      last_coord = Agent.get(coord_storage, fn coords -> Map.get(coords, slope) end)

      if last_coord do
        result =
          last_coord
          |> apply_slope(slope)
          |> Stream.iterate(&apply_slope(&1, slope))
          |> Stream.map(fn {x, y} = c ->
            {slope, c}
            cond do
              x not in asteroid_map.meta.x_range -> {:out_of_range, slope, c}
              y not in asteroid_map.meta.y_range -> {:out_of_range, slope, c}
              asteroid_map.map[c] |> asteroid?() -> {:hit, slope, c}
              true -> :nothing_found # nothing found, keep looking along slope
            end
          end)
          |> Stream.drop_while(fn
            :nothing_found -> true
            _ -> false
          end)
          |> Enum.take(1)
          |> List.first()

        case result do
          {:out_of_range, s, _} ->
            Agent.update(coord_storage, fn last_coord -> Map.delete(last_coord, s) end)

          {:hit, s, c} ->
            Storage.destroy_asteroid(storage, c)
            Agent.update(coord_storage, fn last_coord -> %{last_coord | s => c} end)
        end
      end
    end)
    |> Stream.take_while(fn _ ->
      Agent.get(coord_storage, fn last_coords -> map_size(last_coords) > 0 end)
    end)
    |> Stream.run()

    Agent.stop(coord_storage)
    Storage.stop(storage)
  end
end
