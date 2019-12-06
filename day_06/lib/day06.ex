defmodule Day06 do
  def run() do
    {origin, orbit_map, objects} =
      Orbits.Data.data()
      |> massage()

    {:ok, d_agent} = Agent.start(fn -> objects end)

    traverse(orbit_map, origin, d_agent, 0)

    checksum =
      d_agent
      |> Agent.get(fn distances -> distances end)
      |> Enum.map(fn {_, d} -> d end)
      |> Enum.sum()

    Agent.stop(d_agent)

    checksum
  end

  def massage(data) do
    orbit_pairs =
      data
      |> String.split("\n", trim: true)
      |> Enum.map(&String.split(&1, ")", trim: true))

    orbit_map =
      orbit_pairs
      |> Enum.group_by(fn [a, _] -> a end, fn [_, b] -> b end)
      |> Enum.map(fn {a, bs} ->
        {a, Enum.map(bs, fn b -> {b, -1} end)}
      end)
      |> Enum.into(%{})

    objects =
      orbit_pairs
      |> Enum.flat_map(fn [a, b] -> [{a, -1}, {b, -1}] end)
      |> Enum.into(%{})

    {"COM", orbit_map, objects}
  end

  def traverse(orbit_map, origin, d_agent, distance) do
    Agent.update(d_agent, fn distances -> %{distances | origin => distance} end)

    objects = orbit_map[origin]

    unless objects == nil do
      objects
      |> Enum.each(fn {object, _} ->
        traverse(orbit_map, object, d_agent, distance + 1)
      end)
    end
  end

  def part2() do
    {_origin, orbit_map, _objects} =
      Orbits.Data.data()
      |> massage()

    bidirectional_orbit_map =
      orbit_map
      |> make_bi_orbit_map()
      |> IO.inspect(label: "72")

    find_path("YOU", bidirectional_orbit_map, -1, "SAN")
  end

  def make_bi_orbit_map(map) do
    map =
      map
      |> Enum.map(fn {a, bs} -> {a, Enum.map(bs, fn {b, _} -> b end)} end)
      |> Enum.into(%{})

    map
    |> Enum.reduce(map, fn {a, bs}, nmap ->
      Enum.reduce(bs, nmap, fn b, nmap ->
        edges = nmap[b]

        case edges do
          nil -> Map.put(nmap, b, [a])
          l -> Map.put(nmap, b, [a | l])
        end
      end)
    end)
  end

  def find_path(obj, orbit_map, count, target) do
    edges = orbit_map[obj]

    cond do
      target in edges ->
        {:ok, count}

      true ->
        Enum.find_value(edges, fn edge ->
          orbit_map = remove_edge_from_possibilities(orbit_map, obj, edge)

          find_path(edge, orbit_map, count + 1, target)
        end)
    end
  end

  def remove_edge_from_possibilities(orbit_map, obj, edge) do
    orbit_map
    |> Map.put(obj, List.delete(orbit_map[obj], edge))
    |> Map.put(edge, List.delete(orbit_map[edge],obj))
  end
end
