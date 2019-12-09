defmodule AmplifierTest do
  use ExUnit.Case

  test "1" do
    program = "3,15,3,16,1002,16,10,16,1,16,15,15,4,15,99,0,0"
    sequence = [4,3,2,1,0]
    result = 43210

    assert PhaseAmplifier.sequence(program, sequence) == result
  end


  test "2" do
    program = "3,23,3,24,1002,24,10,24,1002,23,-1,23,101,5,23,23,1,24,23,23,4,23,99,0,0"
    sequence = [0,1,2,3,4]
    result = 54321

    assert PhaseAmplifier.sequence(program, sequence) == result
  end


  test "3" do
    program = "3,31,3,32,1002,32,10,32,1001,31,-2,31,1007,31,0,33,1002,33,7,33,1,33,31,31,1,32,31,31,4,31,99,0,0,0"
    sequence = [1,0,4,3,2]
    result = 65210

    assert PhaseAmplifier.sequence(program, sequence) == result
  end

  test "f1" do
    program = "3,26,1001,26,-4,26,3,27,1002,27,2,27,1,27,26,27,4,27,1001,28,-1,28,1005,28,6,99,0,0,5"
    sequence = [9,8,7,6,5]
    result = 139629729

    assert PhaseAmplifier.feedback_sequence(program, sequence) == result
  end

  test "f2" do
    program = "3,52,1001,52,-5,52,3,53,1,52,56,54,1007,54,5,55,1005,55,26,1001,54,-5,54,1105,1,12,1,53,54,53,1008,54,0,55,1001,55,1,55,2,53,55,53,4,53,1001,56,-1,56,1005,56,6,99,0,0,0,0,10"
    sequence = [9,7,8,5,6]
    result = 18216

    assert PhaseAmplifier.feedback_sequence(program, sequence) == result
  end


  test "part 2" do
    program = VMRunner.day_7_instructions()

    {max_seq, result} = PhaseAmplifier.find_max_feedback_amplification(program)

    assert result == 35961106
    assert max_seq == [7, 8, 6, 9, 5]
  end
end
