defmodule BoostTest do
  use ExUnit.Case

  test "a" do
    program = "1,0,0,3,109,3,2201,0,0,0,99"

    assert VMRunner.test(program, []) == {[4, 0, 0, 2, 109, 3, 2201, 0, 0, 0, 99], []}
  end

  @tag :boost
  test "1" do
    program = fn i ->
      VMRunner.test("109,1,204,-1,1001,100,1,100,1008,100,16,101,1006,101,0,99", i)
    end

    program_1 = fn -> program.([]) end
    {_, out} = program_1.()
    assert out == [109,1,204,-1,1001,100,1,100,1008,100,16,101,1006,101,0,99]
  end


  test "2" do
    program = "1102,34915192,34915192,7,4,7,99,0"
    assert VMRunner.test(program, []) == {[1102, 34915192, 34915192, 7, 4, 7, 99, 1219070632396864], [1219070632396864]}
  end



  test "3" do
    program = "104,1125899906842624,99"
    assert VMRunner.test(program, []) == {[104,1125899906842624,99], [1125899906842624]}
  end

  test "part 1" do
    program = VMRunner.day_9_instructions()
    assert VMRunner.test(program, [1]) |> elem(1) == [3429606717]
  end

  test "part 2" do
    program = VMRunner.day_9_instructions()
    assert VMRunner.test(program, [2]) |> elem(1) == [33679]
  end
end
