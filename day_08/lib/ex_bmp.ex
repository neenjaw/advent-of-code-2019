defmodule ExBmp do
  @moduledoc """
  Defines a struct representing a decoded bmp file.
  """

  defstruct [
    # BITMAPFILEHEADER
    :file_size,
    :pixel_data_offset,

    # BITMAPV5HEADER
    :header_size,
    :image_width,
    :image_height,
    :planes,
    :bits_per_pixel,
    :compression,
    :image_size,
    :x_pixels_per_meter,
    :y_pixels_per_meter,
    :colors_in_color_table,
    :important_color_count,
    :red_channel_bitmask,
    :green_channel_bitmask,
    :blue_channel_bitmask,
    :alpha_channel_bitmask,
    :color_space_type,
    :color_space_endpoints,
    :gamma_for_red_channel,
    :gamma_for_green_channel,
    :gamma_for_blue_channel,
    :intent,
    :icc_profile_size,
    :icc_profile_data,
    :color_table,
    :pixel_data,
    :icc_color_profile,
  ]

  @bitmapv5header_length 124

  @reverse_as_binary [
    :red_channel_bitmask,
    :green_channel_bitmask,
    :blue_channel_bitmask,
    :alpha_channel_bitmask,
    :pixel_data
  ]

  @reverse_as_string [
    :color_space_type
  ]

  @dont_reverse [
    :color_table
  ]

  @doc """
  Takes a binary representing a bitmap, pattern matches on the headersize to determine the
  format of the header for parsing.  The binary is then passed to the appropriate decoder.

  The decoder will then return a struct with the image data.

  All data in a bitmap is encoded as little endian format, so it has been decoded and
  reversed as appropriate for easier reading/parsing.

  For more information on the bitmap format, see: https://en.wikipedia.org/wiki/BMP_file_format
  """
  def decode_bmp(
        <<
          "BM",
          _file_size :: binary-size(4),
          _reserverd_1 :: binary-size(2),
          _reserverd_2 :: binary-size(2),
          _pixel_data_offset :: binary-size(4),
          header_size :: binary-size(4),
          _remaining :: binary
        >> = bmp_data)
  do
    header_size
    |> :binary.decode_unsigned(:little)
    |> case do
      @bitmapv5header_length ->
        do_decode_bmp(@bitmapv5header_length, bmp_data)

      _ ->
        raise ArgumentError, "unsupported bmp format"
    end
  end

  defp do_decode_bmp(
        @bitmapv5header_length,
        <<
          # BITMAPFILEHEADER
          "BM",
          file_size :: binary-size(4),
          _reserverd_1 :: binary-size(2),
          _reserverd_2 :: binary-size(2),
          pixel_data_offset :: binary-size(4),

          # BITMAPV5HEADER
          header_size :: binary-size(4),
          image_width :: binary-size(4),
          image_height :: binary-size(4),
          planes :: binary-size(2),
          bits_per_pixel :: binary-size(2),
          compression :: binary-size(4),
          image_size :: binary-size(4),
          x_pixels_per_meter :: binary-size(4),
          y_pixels_per_meter :: binary-size(4),

          colors_in_color_table :: binary-size(4),
          important_color_count :: binary-size(4),

          red_channel_bitmask :: binary-size(4),
          green_channel_bitmask :: binary-size(4),
          blue_channel_bitmask :: binary-size(4),
          alpha_channel_bitmask :: binary-size(4),

          color_space_type :: binary-size(4),
          color_space_endpoints :: binary-size(4),

          gamma_for_red_channel :: binary-size(4),
          gamma_for_green_channel :: binary-size(4),
          gamma_for_blue_channel :: binary-size(4),

          intent :: binary-size(4),

          icc_profile_data :: binary-size(4),
          icc_profile_size :: binary-size(4),

          _reserved_3 :: binary-size(4),

          # COLOR_TABLE, PIXEL_DATA, ICC_DATA, GAPS
          _remaining :: binary
        >> = bmp_data)
  do
    # Gather data for reversal/decoding
    bmp =
      [
        # # BITMAPFILEHEADER
        file_size: file_size,
        pixel_data_offset: pixel_data_offset,

        # # BITMAPINFOHEADER
        header_size: header_size,
        image_width: image_width,
        image_height: image_height,
        planes: planes,
        bits_per_pixel: bits_per_pixel,
        compression: compression,
        image_size: image_size,
        x_pixels_per_meter: x_pixels_per_meter,
        y_pixels_per_meter: y_pixels_per_meter,

        #

        colors_in_color_table: colors_in_color_table,
        important_color_count: important_color_count,

        red_channel_bitmask: red_channel_bitmask,
        green_channel_bitmask: green_channel_bitmask,
        blue_channel_bitmask: blue_channel_bitmask,
        alpha_channel_bitmask: alpha_channel_bitmask,

        color_space_type: color_space_type,
        color_space_endpoints: color_space_endpoints,

        gamma_for_red_channel: gamma_for_red_channel,
        gamma_for_green_channel: gamma_for_green_channel,
        gamma_for_blue_channel: gamma_for_blue_channel,

        intent: intent,

        icc_profile_data: icc_profile_data,
        icc_profile_size: icc_profile_size,
      ]
      |> Enum.map(fn
        {k, b} when k in @reverse_as_binary ->
          {k, b |> :binary.bin_to_list() |> Enum.reverse() |> :binary.list_to_bin()}

        {k, rs} when k in @reverse_as_string ->
          {k, rs |> String.reverse()}

        {k, _} = p when k in @dont_reverse ->
          p

        {k, little} ->
          {k, :binary.decode_unsigned(little, :little)}
      end)

    # Calculate offsets for pattern matching the binary for remaining fields
    file_size = bmp[:file_size]
    header_size = bmp[:header_size]
    colors_in_color_table = bmp[:colors_in_color_table]
    pixel_data_offset = bmp[:pixel_data_offset]
    gap_1_size = pixel_data_offset - colors_in_color_table - header_size - 14
    pixel_size = bmp[:image_size]
    icc_profile_size = bmp[:icc_profile_size]
    gap_2_size = file_size - pixel_data_offset - pixel_size - icc_profile_size

    <<
      _file_header :: binary-size(14),
      _v5_header :: binary-size(header_size),
      color_table :: binary-size(colors_in_color_table),
      _gap_1 :: binary-size(gap_1_size),
      pixel_data :: binary-size(pixel_size),
      _gap_2 :: binary-size(gap_2_size),
      icc_color_profile :: binary-size(icc_profile_size)
    >> = bmp_data

    # Calculate pixel data encoding
    row_width = :math.ceil(bmp[:bits_per_pixel] * bmp[:image_width] / 32) * 4 |> Kernel.trunc()
    bytes_per_pixel = div(bmp[:bits_per_pixel], 8)
    bytes_per_image_row = bmp[:image_width] * bytes_per_pixel

    # Reverse the pixel data
    pixel_data =
      pixel_data
      |> :binary.bin_to_list()
      |> Enum.chunk_every(row_width)
      |> Enum.map(fn c ->
        c
        |> Enum.take(bytes_per_image_row)
        |> Enum.chunk_every(bytes_per_pixel)
        |> Enum.map(fn c -> c |> Enum.reverse |> :binary.list_to_bin() end)
      end)
      |> Enum.reverse()

    %__MODULE__{
      file_size: bmp[:file_size],
      pixel_data_offset: bmp[:pixel_data_offset],
      header_size: bmp[:header_size],
      image_width: bmp[:image_width],
      image_height: bmp[:image_height],
      planes: bmp[:planes],
      bits_per_pixel: bmp[:bits_per_pixel],
      compression: bmp[:compression],
      image_size: bmp[:image_size],
      x_pixels_per_meter: bmp[:x_pixels_per_meter],
      y_pixels_per_meter: bmp[:y_pixels_per_meter],
      colors_in_color_table: bmp[:colors_in_color_table],
      important_color_count: bmp[:important_color_count],
      red_channel_bitmask: bmp[:red_channel_bitmask],
      green_channel_bitmask: bmp[:green_channel_bitmask],
      blue_channel_bitmask: bmp[:blue_channel_bitmask],
      alpha_channel_bitmask: bmp[:alpha_channel_bitmask],
      color_space_type: bmp[:color_space_type],
      color_space_endpoints: bmp[:color_space_endpoints],
      gamma_for_red_channel: bmp[:gamma_for_red_channel],
      gamma_for_green_channel: bmp[:gamma_for_green_channel],
      gamma_for_blue_channel: bmp[:gamma_for_blue_channel],
      icc_profile_size: bmp[:icc_profile_size],
      intent: bmp[:intent],
      icc_profile_data: icc_profile_data,
      color_table: color_table,
      pixel_data: pixel_data,
      icc_color_profile: icc_color_profile,
    }
  end
end
