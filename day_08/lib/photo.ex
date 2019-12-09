defmodule Photo do
  defstruct height: nil, width: nil, data: [], layers: []

  alias Photo.Layer

  def new(height, width, data) do
    layers =
      data
      |> Enum.chunk_every(height * width)
      |> Enum.map(fn chunk ->
        Layer.new(height, width, chunk)
      end)

    %Photo{height: height, width: width, data: data, layers: layers}
  end

  def all_layers_valid?(%Photo{} = p) do
    p.layers
    |> Enum.all?(fn l -> Layer.valid?(l) end)
  end

  def merge_layers(%Photo{} = photo) do
    merged_layer =
      photo.layers
      |> Enum.map(fn l -> l.pixels end)
      |> Enum.reduce(fn data, merged_data ->
        Enum.zip(merged_data, data)
        |> Enum.map(fn
          # {front, back}
          {2, p} -> p
          {p, _} -> p
        end)
      end)
      |> (fn d -> Layer.new(25, 6, d) end).()

    %{photo | layers: [merged_layer]}
  end

  def draw_photo_as_text(%Photo{} = photo) do
    photo
    |> Photo.merge_layers()
    |> Map.get(:layers)
    |> hd
    |> Map.get(:pixels)
    |> Enum.map(fn
      1 -> "W"
      _ -> " "
    end)
    |> Enum.chunk_every(25)
    |> Enum.map_join("\n", &Enum.join(&1))
    |> IO.puts()

    photo
  end

  def draw_photo_as_bmp(%Photo{} = photo) do
    %{width: _w, height: _h, layers: [_l]} = merge_layers(photo)


  end
end
