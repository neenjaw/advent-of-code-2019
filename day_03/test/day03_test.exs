defmodule Day03Test do
  use ExUnit.Case
  doctest Day03

  test "ex 1" do
    a = "R75,D30,R83,U83,L12,D49,R71,U7,L72"
    b = "U62,R66,U55,R34,D71,R55,D58,R83"
    distance = 159

    assert Day03.run(a, b) == distance
  end

  test "ex 2" do
    a = "R98,U47,R26,D63,R33,U87,L62,D20,R33,U53,R51"
    b = "U98,R91,D20,R16,D67,R40,U7,R15,U6,R7"
    distance = 135

    assert Day03.run(a, b) == distance
  end
end
