defmodule Intcode.Default do
  def get_input() do
    {value, _} = IO.gets("integer input? ") |> Integer.parse()

    value
  end

  def output(value) do
    value |> inspect() |> IO.puts()
  end
end
