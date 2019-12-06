defmodule IntcodeTest do
  use ExUnit.Case

  @intcode_tests [
    {
      "1",
      [1, 0, 0, 0, 99],
      [2, 0, 0, 0, 99]
    },
    {
      "2",
      [2, 3, 0, 3, 99],
      [2, 3, 0, 6, 99]
    },
    {
      "3",
      [2, 4, 4, 5, 99, 0],
      [2, 4, 4, 5, 99, 9801]
    },
    {
      "4",
      [1, 1, 1, 4, 99, 5, 6, 0, 99],
      [30, 1, 1, 4, 2, 5, 6, 0, 99]
    },
    {
      "5",
      [1, 9, 10, 3, 2, 3, 11, 0, 99, 30, 40, 50],
      [3500, 9, 10, 70, 2, 3, 11, 0, 99, 30, 40, 50]
    },
    {
      "6",
      [1002, 4, 3, 4, 33],
      [1002, 4, 3, 4, 99]
    }
  ]

  for {name, left, right} <- @intcode_tests do
    @name name
    @left left
    @right right
    test "program #{@name}" do
      assert Intcode.run(@left) == @right
    end
  end

  test "input equals - position mode" do
    program = fn i ->
      Day05.test("3, 9, 8, 9, 10, 9, 4, 9, 99, -1, 8", i)
    end

    program_1 = fn -> program.([8]) end
    {_, out} = program_1.()
    assert out == [1]

    program_2 = fn -> program.([7]) end
    {_, out} = program_2.()
    assert out == [0]

    program_3 = fn -> program.([9]) end
    {_, out} = program_3.()
    assert out == [0]
  end

  test "input less than - position mode" do
    program = fn i ->
      Day05.test("3, 9, 7, 9, 10, 9, 4, 9, 99, -1, 8", i)
    end

    program_1 = fn -> program.([8]) end
    {_, out} = program_1.()
    assert out == [0]

    program_2 = fn -> program.([7]) end
    {_, out} = program_2.()
    assert out == [1]

    program_3 = fn -> program.([9]) end
    {_, out} = program_3.()
    assert out == [0]
  end

  test "input equals - immediate mode" do
    program = fn i ->
      Day05.test("3,3,1108,-1,8,3,4,3,99", i)
    end

    program_1 = fn -> program.([8]) end
    {_, out} = program_1.()
    assert out == [1]

    program_2 = fn -> program.([7]) end
    {_, out} = program_2.()
    assert out == [0]

    program_3 = fn -> program.([9]) end
    {_, out} = program_3.()
    assert out == [0]
  end

  test "input less than - immediate mode" do
    program = fn i ->
      Day05.test("3,3,1107,-1,8,3,4,3,99", i)
    end

    program_1 = fn -> program.([8]) end
    {_, out} = program_1.()
    assert out == [0]

    program_2 = fn -> program.([7]) end
    {_, out} = program_2.()
    assert out == [1]

    program_3 = fn -> program.([9]) end
    {_, out} = program_3.()
    assert out == [0]
  end

  # @tag :pending
  test "jump - position mode" do
    program = fn i ->
      #           0 1  2 3  4  5 6  7  8  9 10 11 12 13 14 15
      Day05.test("3,12,6,12,15,1,13,14,13,4,13,99,-1,0, 1, 9", i)
    end

    program_1 = fn -> program.([0]) end
    {_, out} = program_1.()
    assert out == [0]

    program_2 = fn -> program.([1]) end
    {_, out} = program_2.()
    assert out == [1]

    program_3 = fn -> program.([-1]) end
    {_, out} = program_3.()
    assert out == [1]
  end

  test "jump - immediate mode" do
    program = fn i ->
      Day05.test("3,3,1105,-1,9,1101,0,0,12,4,12,99,1", i)
    end

    program_1 = fn -> program.([0]) end
    {_, out} = program_1.()
    assert out == [0]

    program_2 = fn -> program.([1]) end
    {_, out} = program_2.()
    assert out == [1]

    program_3 = fn -> program.([-1]) end
    {_, out} = program_3.()
    assert out == [1]
  end

  test "larger" do
    code = """
      3,21,1008,21,8,20,1005,20,22,107,8,21,20,1006,20,31,1106,0,36,98,0,0,1002,21,125,20,4,20,1105,1,46,104,999,1105,1,46,1101,1000,1,20,4,20,1105,1,46,98,99
      """
    program = fn i ->
      Day05.test(code, i)
    end

    program_1 = fn -> program.([7]) end
    {_, out} = program_1.()
    assert out == [999]

    program_2 = fn -> program.([8]) end
    {_, out} = program_2.()
    assert out == [1000]

    program_3 = fn -> program.([9]) end
    {_, out} = program_3.()
    assert out == [1001]
  end

  test "final" do
    {_, out} = Day05.default()
    assert out == [8346937]
  end
end
