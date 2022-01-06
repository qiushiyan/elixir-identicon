defmodule Identicon do
  @moduledoc """
  Generate github-like identicons from a string
  """

  def main(input, filename) do
    input
    |> hash_input()
    |> pick_color()
    |> build_grid()
    |> filter_odd_squares()
    |> build_pixel_map()
    |> draw_image()
    |> save_image(filename)
  end

  def save_image(image_obj, filename) do
    File.write("#{filename}.png", image_obj)
    "Generated #{filename}.png"
  end

  def draw_image(%Identicon.Image{color: color, pixel_map: pixel_map}) do
    image = :egd.create(250, 250)
    fill = :egd.color(color)

    Enum.each(pixel_map, fn {start, stop} ->
      :egd.filledRectangle(image, start, stop, fill)
    end)

    :egd.render(image)
  end

  def build_pixel_map(%Identicon.Image{grid: grid} = image) do
    pixel_map =
      Enum.map(grid, fn {_code, index} ->
        h = rem(index, 5) * 50
        v = div(index, 5) * 50

        top_left = {h, v}
        bottom_right = {h + 50, v + 50}
        {top_left, bottom_right}
      end)

    %Identicon.Image{image | pixel_map: pixel_map}
  end

  def pick_color(%Identicon.Image{hex: [r, g, b | _tail]} = image) do
    %Identicon.Image{image | color: {r, g, b}}
  end

  def build_grid(%Identicon.Image{hex: hex} = image) do
    grid =
      hex
      |> Stream.chunk_every(3)
      |> Stream.filter(fn x -> length(x) === 3 end)
      |> Enum.map(&mirrow_row/1)
      |> List.flatten()
      |> Stream.with_index()

    %Identicon.Image{image | grid: grid}
  end

  def mirrow_row(row) do
    [first, second, _tail] = row
    row ++ [second, first]
  end

  def filter_odd_squares(%Identicon.Image{grid: grid} = image) do
    grid =
      grid
      |> Stream.filter(fn {code, _index} -> rem(code, 2) == 1 end)

    %Identicon.Image{image | grid: grid}
  end

  def hash_input(input) do
    hex =
      :crypto.hash(:md5, input)
      |> :binary.bin_to_list()

    %Identicon.Image{hex: hex}
  end
end
