defmodule Photo.Bmp.Colors do
  @moduledoc false

  # from mars color to sRGB color
  def translate_mars_color(2), do: <<0, 0, 0, 0>>
  def translate_mars_color(1), do: <<255, 255, 255, 255>>
  def translate_mars_color(0), do: <<255, 0, 0, 0>>
end
