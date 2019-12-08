defmodule Day08 do
  @moduledoc false

  alias Photo.Layer

  def read_input() do
    {:ok, contents} = File.read("input")

    contents
    |> to_charlist()
    |> Enum.map(fn c -> c - 48 end)
  end

  def derive_part1() do
    data = read_input()

    photo = Photo.new(25, 6, data)

    # Photo.all_layers_valid?(photo)

    [_, {1, x}, {2, y}] =
      photo.layers
      |> Enum.map(&Layer.count_pixels/1)
      |> Enum.min_by(fn [{0, n} | _] -> n end)

    x*y
  end

  def derive_part2() do
    data = read_input()

    photo = Photo.new(25, 6, data)

    photo
    |>Photo.draw_photo_as_text()

    :ok
  end
end
