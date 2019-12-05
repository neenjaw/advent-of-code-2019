defmodule Runner do
  # def look_for_answer(n \\ 99) do
  #   possibilities =
  #     for a <- 0..n,
  #         b <- n..0 do
  #       {a, b}
  #     end

  #   possibilities
  #   |> Stream.map(fn {a, b} ->
  #     @instructions
  #     |> List.replace_at(1, a)
  #     |> List.replace_at(2, b)
  #   end)
  #   |> Task.async_stream(&test_instructions(&1), max_concurrency: 25)
  #   |> Stream.map(fn {:ok, e} -> e end)
  #   |> Enum.find(fn
  #     {_, _} -> true
  #     _ -> false
  #   end)
  # end

  # def test_instructions(instructions) do
  #   [_, noun, verb | _] = instructions

  #   result =
  #     case Intcode.run(instructions) do
  #       :error -> 0
  #       [r | _] -> r
  #     end

  #   if result == 19690720 do
  #     {noun, verb}
  #   else
  #     :no
  #   end
  # end
end
