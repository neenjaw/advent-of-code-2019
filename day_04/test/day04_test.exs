defmodule Day04Test do
  use ExUnit.Case
  doctest Day04

  test "v1" do
    password = 111111

    assert Day04.check_one(password)
    refute Day04.check_two(password)
  end

  test "v2" do
    password = 223450

    refute Day04.check_one(password)
    refute Day04.check_two(password)
  end

  test "v3" do
    password = 123789

    refute Day04.check_one(password)
    refute Day04.check_two(password)
  end

  test "v4" do
    password = 112233

    assert Day04.check_one(password)
    assert Day04.check_two(password)
  end

  test "v5" do
    password = 123444

    assert Day04.check_one(password)
    refute Day04.check_two(password)
  end

  test "v6" do
    password = 111122

    assert Day04.check_one(password)
    assert Day04.check_two(password)
  end

  test "problem" do
    assert Day04.problem() == 931
  end


  test "problem2" do
    assert Day04.problem2() |> IO.inspect(label: "53") != 481
  end
end
