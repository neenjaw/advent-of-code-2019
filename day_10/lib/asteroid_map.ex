defmodule AsteroidMap do
  defstruct map: nil, meta: %{}, counts: %{}

  alias __MODULE__, as: AM

  @asteroid "#"
  @station "X"

  defguard is_coordinate(xy)
           when is_tuple(xy) and tuple_size(xy) == 2 and is_integer(elem(xy, 0)) and
                  is_integer(elem(xy, 1))

  def parse_string_map(map_as_string) do
    map_as_string
    |> String.split("\n", trim: true)
    |> Enum.map(&String.graphemes/1)
    |> convert_to_struct()
    |> generate_slope_mutations()
  end

  def convert_to_struct(map_as_lists) do
    map =
      map_as_lists
      |> Enum.with_index()
      |> Enum.flat_map(fn {row, y} ->
        row
        |> Enum.with_index()
        |> Enum.map(fn {e, x} ->
          {{x, y}, e}
        end)
      end)
      |> Enum.into(%{})

    width = map_as_lists |> hd() |> length()
    height = map_as_lists |> length()

    meta =
      %{}
      |> put_in([:width], width)
      |> put_in([:height], height)
      |> put_in([:x_range], 0..(width - 1))
      |> put_in([:y_range], 0..(height - 1))

    %__MODULE__{map: map, meta: meta}
  end

  def asteroid?(@asteroid), do: true
  def asteroid?(_), do: false

  def station?(@station), do: true
  def station?(_), do: false

  def asteroid?(%AM{} = asteroid_map, xy) when is_coordinate(xy) do
    if asteroid_map.map[xy] == @asteroid, do: true, else: false
  end

  def generate_slope_mutations(%AM{meta: %{height: h, width: w}} = am) do
    muts = [
      {1, 1},
      {1, -1},
      {-1, -1},
      {-1, 1}
    ]

    right_angle_slope = [
      {1, 0},
      {0, 1},
      {-1, 0},
      {0, -1}
    ]

    not_duplicate_slope = fn
      1, 1 -> true
      x, x -> false
      _, _ -> true
    end

    slopes = for x <- 1..w, y <- 1..h, not_duplicate_slope.(x, y), do: {x, y}

    # filter unreduced slopes
    slopes =
      slopes
      |> Enum.filter(fn
        {1, _} ->
          true

        {_, 1} ->
          true

        coord ->
          not exists_reduced_slope?(slopes, coord)
      end)

    # compute quadrant slopes and add right angle slopes
    slopes =
      slopes
      |> Enum.flat_map(fn {x, y} ->
        Enum.map(muts, fn {mx, my} -> {mx * x, my * y} end)
      end)
      |> Kernel.++(right_angle_slope)

    %{am | meta: Map.put(am.meta, :slopes, slopes)}
  end

  def exists_reduced_slope?(slopes, coord) do
    Enum.any?(slopes, &is_reduced_slope?(coord, &1))
  end

  def is_reduced_slope?({x, y}, {a, b}) when x > a and y > b and x > y and a > b do
    r = div(x, a)

    rem(x, a) == 0 and rem(y, r) == 0
  end

  def is_reduced_slope?({x, y}, {a, b}) when x > a and y > b and y > x and b > a do
    r = div(y, b)

    rem(y, b) == 0 and rem(x, r) == 0
  end

  def is_reduced_slope?(_, _), do: false

  def generate_ordered_slope_mutations(%AM{meta: %{height: h, width: w}} = am) do
    muts = [
      {1, 1},
      {1, -1},
      {-1, -1},
      {-1, 1}
    ]

    right_angle_slope = [
      {1, 0},
      {0, 1},
      {-1, 0},
      {0, -1}
    ]

    not_duplicate_slope = fn
      1, 1 -> true
      x, x -> false
      _, _ -> true
    end

    slopes = for x <- 1..w, y <- 1..h, not_duplicate_slope.(x, y), do: {x, y}

    # filter unreduced slopes
    slopes =
      slopes
      |> Enum.filter(fn
        {1, _} ->
          true

        {_, 1} ->
          true

        coord ->
          not exists_reduced_slope?(slopes, coord)
      end)

    # compute quadrant slopes and add right angle slopes
    slopes =
      slopes
      |> Enum.flat_map(fn {x, y} ->
        Enum.map(muts, fn {mx, my} -> {mx * x, my * y} end)
      end)
      |> Kernel.++(right_angle_slope)

    # order the slopes by degrees
    slopes =
      slopes
      |> Enum.map(fn c ->
        {c, angle(c)}
      end)
      |> Enum.sort_by(fn {_, d} -> d end, &<=/2)
      |> Enum.map(&elem(&1, 0))
      # |> Enum.reverse()

    # n_slopes = slopes |> length()

    # slopes =
    #   slopes
    #   |> Stream.cycle()
    #   |> Stream.drop_while(fn coord -> coord != {0, -1} end)
    #   |> Enum.take(n_slopes)

    %{am | meta: Map.put(am.meta, :ordered_slopes, slopes)}
  end

  def angle({x, y}) do
    deg = (:math.atan2(y, x) * 180.0 / :math.pi()) + 90

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
end
