defmodule Photo.Bmp.Header do
  @moduledoc false

  @defaults [
    type: :bitmap_v5_header,

    planes: 1,
    bits_per_pixel: 32,
    compression: 3,
    x_pixels_per_meter: 11811,
    y_pixels_per_meter: 11811,

    colors_in_color_table: 0,
    icc_profile_size: 0,
    important_color_count: 0,

    red_channel_bitmask: <<0,255,0,0>>,
    green_channel_bitmask: <<0,0,255,0>>,
    blue_channel_bitmask: <<0,0,0,255>>,
    alpha_channel_bitmask: <<255,0,0,0>>,
  ]

  def get_default_data(), do: @defaults

  def create_header(width, height, opts \\ []) do
    opts = Keyword.merge(@defaults, opts)

    do_create_file_header(width, height, opts) <>
    do_create_bitmap_header(opts[:type], width, height, opts)
  end

  def do_create_file_header(width, height, opts) do
    file_size =
      calculate_file_size(width, height, opts)

    <<
      "BM",
      file_size :: 4-little,
      0, 0, 0, 0,
      (
        calc_bitmap_file_header_size() +
        calc_bitmap_header_size(opts[:type])
      ) :: 4-little
    >>
  end

  def do_create_bitmap_header(:bitmap_v5_header, width, height, opts) do
    <<
      calc_bitmap_header_size(opts[:type]) :: integer-little,
      # width :: 4-little,
      # height :: 4-little,
      # opts[:planes] :: 2-little,
      # opts[:bits_per_pixel] :: 2-little,
      # opts[:compression] :: 4-little,
      # calc_pixel_array_size(width, height, opts) :: 4-little,
      # opts[:x_pixels_per_meter] :: 4-little,
      # opts[:y_pixels_per_meter] :: 4-little,
      # opts[:colors_in_color_table] :: 4-little,
      # opts[:important_color_count] :: 4-little,
      # opts[:red_channel_bitmask] :: 4-little,
      # opts[:green_channel_bitmask] :: 4-little,
      # opts[:blue_channel_bitmask] :: 4-little,
      # opts[:alpha_channel_bitmask] :: 4-little,

    >>
  end


  #
  # File Size Functions
  #

  def calculate_file_size(width, height, opts) do
    calc_bitmap_file_header_size() +
    calc_bitmap_header_size(opts[:type]) +
    calc_color_table_size(opts) +
    calc_pixel_array_size(width, height, opts) +
    calc_icc_profile_size(opts)
  end

  defp calc_bitmap_file_header_size(), do: 14

  defp calc_bitmap_header_size(:bitmap_v5_header), do: 124

  defp calc_color_table_size(opts), do: opts[:colors_in_color_table] * 4

  defp calc_pixel_array_size(width, height, opts) do
    ((:math.ceil(opts[:bits_per_pixel] * width / 32) * 4) |> Kernel.trunc()) * height
  end

  defp calc_icc_profile_size(opts) do
    opts[:icc_profile_size]
  end
end
