defmodule Day04 do
  @moduledoc """
  Documentation for Day04.
  """

  @left 272091
  @right 815432

  def problem() do
    @left..@right
    |>Enum.filter(&check_one/1)
    |>Enum.count()
  end

  def problem2() do
    @left..@right
    |>Enum.filter(&check_two/1)
    |>Enum.count()
  end

  def check_one(number), do: number |> Integer.digits() |> is_valid()

  def check_two(number), do: number |> Integer.digits() |> (fn nl -> is_valid(nl) and is_still_valid(nl) end).()

  def is_valid([_,_,_,_,_,_] = password) do
    chunked = password |> Enum.chunk_every(2,1,:discard)
    increasing = chunked |> Enum.all?(fn [a,b] -> a <= b end)
    double = chunked |> Enum.any?(fn [a,b] -> a == b end)

    increasing and double
  end

  def is_valid(_), do: false

  def is_still_valid(password) do
    password
    |> Enum.chunk_by(& &1)
    |> Enum.any?(&(length(&1) == 2))
  end
end
