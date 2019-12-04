defmodule Runner do
  @instructions [
    1,
    0,
    0,
    3,
    1,
    1,
    2,
    3,
    1,
    3,
    4,
    3,
    1,
    5,
    0,
    3,
    2,
    1,
    9,
    19,
    1,
    19,
    5,
    23,
    2,
    23,
    13,
    27,
    1,
    10,
    27,
    31,
    2,
    31,
    6,
    35,
    1,
    5,
    35,
    39,
    1,
    39,
    10,
    43,
    2,
    9,
    43,
    47,
    1,
    47,
    5,
    51,
    2,
    51,
    9,
    55,
    1,
    13,
    55,
    59,
    1,
    13,
    59,
    63,
    1,
    6,
    63,
    67,
    2,
    13,
    67,
    71,
    1,
    10,
    71,
    75,
    2,
    13,
    75,
    79,
    1,
    5,
    79,
    83,
    2,
    83,
    9,
    87,
    2,
    87,
    13,
    91,
    1,
    91,
    5,
    95,
    2,
    9,
    95,
    99,
    1,
    99,
    5,
    103,
    1,
    2,
    103,
    107,
    1,
    10,
    107,
    0,
    99,
    2,
    14,
    0,
    0
  ]

  def look_for_answer(n \\ 99) do
    possibilities =
      for a <- 0..n,
          b <- n..0 do
        {a, b}
      end

    possibilities
    |> Stream.map(fn {a, b} ->
      @instructions
      |> List.replace_at(1, a)
      |> List.replace_at(2, b)
    end)
    |> Task.async_stream(&test_instructions(&1), max_concurrency: 25)
    |> Stream.map(fn {:ok, e} -> e end)
    |> Enum.find(fn
      {_, _} -> true
      _ -> false
    end)
  end

  def test_instructions(instructions) do
    [_, noun, verb | _] = instructions

    result =
      case Intcode.run(instructions) do
        :error -> 0
        [r | _] -> r
      end

    if result == 19690720 do
      {noun, verb}
    else
      :no
    end
  end
end
