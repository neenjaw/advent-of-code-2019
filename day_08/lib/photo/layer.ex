defmodule Photo.Layer do
  defstruct [height: nil, width: nil, pixels: []]

  alias Photo.Layer

  def new(height, width, pixels) do
    %Layer{height: height, width: width, pixels: pixels}
  end

  def valid?(%Layer{} = l) do
    length(l.pixels) == (l.height * l.width)
  end

  def count_pixels(%Layer{} = layer) do
    layer.pixels
    |> Enum.group_by(&(&1), fn _ -> 1 end)
    |> Enum.map(fn {c, l} -> {c, Enum.sum(l)} end)
  end
end
