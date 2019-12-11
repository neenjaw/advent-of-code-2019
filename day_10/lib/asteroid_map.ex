defmodule AsteroidMap do
  defstruct map: nil, meta: %{}, asteroids: []

  alias __MODULE__, as: AM

  @asteroid "#"
  @station "X"

  def parse_string_map(map_as_string) do
    map_as_string
    |> String.split("\n", trim: true)
    |> Enum.map(&String.graphemes/1)
    |> convert_to_struct()
  end

  def convert_to_struct(map_as_lists) do
    list =
      map_as_lists
      |> Enum.with_index()
      |> Enum.flat_map(fn {row, y} ->
        row
        |> Enum.with_index()
        |> Enum.map(fn {e, x} ->
          {{x, y}, e}
        end)
      end)

    map =
      list
      |> Enum.into(%{})

    asteroid_list =
      list
      |> Enum.filter(fn {_, o} -> asteroid?(o) end)
      |> Enum.map(fn {c, _} -> c end)

    %__MODULE__{map: map, asteroids: asteroid_list}
  end

  def asteroid?(@asteroid), do: true
  def asteroid?(_), do: false

  def station?(@station), do: true
  def station?(_), do: false

  def generate_asteroid_visibility({x, y} = asteroid, %AM{} = asteroids) do
    result =
      for target <- asteroids.asteroids,
          target != asteroid,
          {x1, y1} = target,
          {dx, dy} = {x - x1, y - y1},
          angle = angle(dx, dy),
          distance = distance(dx, dy)
      do
        {target, angle, distance}
      end
      |> Enum.group_by(fn {_, a, _} -> a end, fn {t, _, d} -> {t, d} end)

    {asteroid, result}
  end

  def angle(dx, dy) do
    deg = (:math.atan2(dy, dx) * 180.0 / :math.pi()) - 90

    deg =
      if deg < 0 do
        deg + 360
      else
        deg
      end

    if deg == 360.0 do
      0.0
    else
      deg
    end
  end

  def distance(dx, dy) do
    :math.sqrt((dx * dx) + (dy * dy))
  end
end
