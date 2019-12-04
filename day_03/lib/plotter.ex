defmodule Plotter do
  @moduledoc false

  @start_state {{0,0}, []}

  @doc """
  Must be in the form "XN,..." where X is ~w(U D L R), N is any positive integer
  """
  def plot_route(string_path) do
    {_, route} =
      string_path
      |> String.split(",")
      |> Enum.reduce(@start_state, &compute_path/2)
      |> (fn {p, reversed_route} -> {p, Enum.reverse(reversed_route)} end).()

    route
  end

  defp compute_path(instruction, {_point, _path} = acc) do
    <<direction::bytes-size(1)>> <> string_moves = instruction

    {moves, _} = Integer.parse(string_moves)

    compute_instruction(direction, moves, acc)
  end

  defp compute_instruction(direction, n, {_point, _path} = acc) do
    1..n
    |> Enum.reduce(acc, fn _, {point, path} ->
      point = move_point(direction, point)

      {point, [point | path]}
    end)
  end

  defp move_point("U", {x, y}), do: {x, y + 1}
  defp move_point("D", {x, y}), do: {x, y - 1}
  defp move_point("R", {x, y}), do: {x + 1, y}
  defp move_point("L", {x, y}), do: {x - 1, y}
end
