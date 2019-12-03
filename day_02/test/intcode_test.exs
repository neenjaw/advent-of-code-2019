defmodule IntcodeTest do
  use ExUnit.Case
  doctest Intcode

  test "ex 2" do
    l = [1, 0, 0, 0, 99]
    a = [2, 0, 0, 0, 99]

    Intcode.run(l) == a
  end

  test "ex 3" do
    l = [2, 3, 0, 3, 99]
    a = [2, 3, 0, 6, 99]

    Intcode.run(l) == a
  end

  test "ex 4" do
    l = [2, 4, 4, 5, 99, 0]
    a = [2, 4, 4, 5, 99, 9801]

    Intcode.run(l) == a
  end

  test "ex 5" do
    l = [1, 1, 1, 4, 99, 5, 6, 0, 99]
    a = [30, 1, 1, 4, 2, 5, 6, 0, 99]

    Intcode.run(l) == a
  end

  test "ex 1" do
    l = [1, 9, 10, 3, 2, 3, 11, 0, 99, 30, 40, 50]
    a = [3500, 9, 10, 70, 2, 3, 11, 0, 99, 30, 40, 50]

    Intcode.run(l) == a
  end
end
