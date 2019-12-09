defmodule VMRunner do
  @moduledoc false

  def day_5_instructions() do
    """
    3,225,1,225,6,6,1100,1,238,225,104,0,1102,67,92,225,1101,14,84,225,1002,217,69,224,101,-5175,224,224,4,224,102,8,223,223,101,2,224,224,1,224,223,223,1,214,95,224,101,-127,224,224,4,224,102,8,223,223,101,3,224,224,1,223,224,223,1101,8,41,225,2,17,91,224,1001,224,-518,224,4,224,1002,223,8,223,101,2,224,224,1,223,224,223,1101,37,27,225,1101,61,11,225,101,44,66,224,101,-85,224,224,4,224,1002,223,8,223,101,6,224,224,1,224,223,223,1102,7,32,224,101,-224,224,224,4,224,102,8,223,223,1001,224,6,224,1,224,223,223,1001,14,82,224,101,-174,224,224,4,224,102,8,223,223,101,7,224,224,1,223,224,223,102,65,210,224,101,-5525,224,224,4,224,102,8,223,223,101,3,224,224,1,224,223,223,1101,81,9,224,101,-90,224,224,4,224,102,8,223,223,1001,224,3,224,1,224,223,223,1101,71,85,225,1102,61,66,225,1102,75,53,225,4,223,99,0,0,0,677,0,0,0,0,0,0,0,0,0,0,0,1105,0,99999,1105,227,247,1105,1,99999,1005,227,99999,1005,0,256,1105,1,99999,1106,227,99999,1106,0,265,1105,1,99999,1006,0,99999,1006,227,274,1105,1,99999,1105,1,280,1105,1,99999,1,225,225,225,1101,294,0,0,105,1,0,1105,1,99999,1106,0,300,1105,1,99999,1,225,225,225,1101,314,0,0,106,0,0,1105,1,99999,8,226,226,224,102,2,223,223,1005,224,329,1001,223,1,223,1108,677,677,224,1002,223,2,223,1006,224,344,101,1,223,223,1007,226,677,224,102,2,223,223,1005,224,359,101,1,223,223,1007,677,677,224,1002,223,2,223,1006,224,374,101,1,223,223,1108,677,226,224,1002,223,2,223,1005,224,389,1001,223,1,223,108,226,677,224,102,2,223,223,1006,224,404,101,1,223,223,1108,226,677,224,102,2,223,223,1005,224,419,101,1,223,223,1008,677,677,224,102,2,223,223,1005,224,434,101,1,223,223,7,677,226,224,1002,223,2,223,1005,224,449,101,1,223,223,1008,226,226,224,102,2,223,223,1005,224,464,1001,223,1,223,107,226,677,224,1002,223,2,223,1006,224,479,1001,223,1,223,107,677,677,224,102,2,223,223,1005,224,494,1001,223,1,223,1008,226,677,224,102,2,223,223,1006,224,509,1001,223,1,223,1107,677,226,224,102,2,223,223,1005,224,524,101,1,223,223,1007,226,226,224,1002,223,2,223,1006,224,539,1001,223,1,223,107,226,226,224,102,2,223,223,1006,224,554,101,1,223,223,108,677,677,224,1002,223,2,223,1006,224,569,1001,223,1,223,7,226,677,224,102,2,223,223,1006,224,584,1001,223,1,223,8,677,226,224,102,2,223,223,1005,224,599,101,1,223,223,1107,677,677,224,1002,223,2,223,1005,224,614,101,1,223,223,8,226,677,224,102,2,223,223,1005,224,629,1001,223,1,223,7,226,226,224,1002,223,2,223,1006,224,644,1001,223,1,223,108,226,226,224,1002,223,2,223,1006,224,659,101,1,223,223,1107,226,677,224,1002,223,2,223,1006,224,674,101,1,223,223,4,223,99,226
    """
  end

  def day_7_instructions() do
    """
    3,8,1001,8,10,8,105,1,0,0,21,46,59,84,93,110,191,272,353,434,99999,3,9,101,2,9,9,102,3,9,9,1001,9,5,9,102,4,9,9,1001,9,4,9,4,9,99,3,9,101,3,9,9,102,5,9,9,4,9,99,3,9,1001,9,4,9,1002,9,2,9,101,2,9,9,102,2,9,9,1001,9,3,9,4,9,99,3,9,1002,9,2,9,4,9,99,3,9,102,2,9,9,1001,9,5,9,1002,9,3,9,4,9,99,3,9,102,2,9,9,4,9,3,9,102,2,9,9,4,9,3,9,102,2,9,9,4,9,3,9,102,2,9,9,4,9,3,9,101,1,9,9,4,9,3,9,102,2,9,9,4,9,3,9,101,2,9,9,4,9,3,9,101,2,9,9,4,9,3,9,1001,9,1,9,4,9,3,9,101,2,9,9,4,9,99,3,9,102,2,9,9,4,9,3,9,1002,9,2,9,4,9,3,9,1002,9,2,9,4,9,3,9,1001,9,1,9,4,9,3,9,1001,9,2,9,4,9,3,9,101,1,9,9,4,9,3,9,1001,9,2,9,4,9,3,9,1002,9,2,9,4,9,3,9,1001,9,1,9,4,9,3,9,1001,9,2,9,4,9,99,3,9,101,1,9,9,4,9,3,9,1001,9,1,9,4,9,3,9,101,1,9,9,4,9,3,9,101,1,9,9,4,9,3,9,1002,9,2,9,4,9,3,9,1002,9,2,9,4,9,3,9,1002,9,2,9,4,9,3,9,1001,9,1,9,4,9,3,9,102,2,9,9,4,9,3,9,101,1,9,9,4,9,99,3,9,1001,9,1,9,4,9,3,9,102,2,9,9,4,9,3,9,101,1,9,9,4,9,3,9,1002,9,2,9,4,9,3,9,1001,9,2,9,4,9,3,9,101,1,9,9,4,9,3,9,1002,9,2,9,4,9,3,9,1002,9,2,9,4,9,3,9,1001,9,1,9,4,9,3,9,102,2,9,9,4,9,99,3,9,102,2,9,9,4,9,3,9,1002,9,2,9,4,9,3,9,1002,9,2,9,4,9,3,9,1001,9,1,9,4,9,3,9,101,1,9,9,4,9,3,9,102,2,9,9,4,9,3,9,1002,9,2,9,4,9,3,9,101,2,9,9,4,9,3,9,1002,9,2,9,4,9,3,9,1001,9,2,9,4,9,99
    """
  end

  def day_9_instructions() do
    """
    1102,34463338,34463338,63,1007,63,34463338,63,1005,63,53,1102,3,1,1000,109,988,209,12,9,1000,209,6,209,3,203,0,1008,1000,1,63,1005,63,65,1008,1000,2,63,1005,63,904,1008,1000,0,63,1005,63,58,4,25,104,0,99,4,0,104,0,99,4,17,104,0,99,0,0,1102,33,1,1011,1102,1,26,1010,1101,0,594,1029,1101,0,20,1018,1102,38,1,1000,1102,35,1,1001,1101,800,0,1023,1101,0,599,1028,1101,0,34,1013,1101,0,737,1026,1102,21,1,1005,1102,1,0,1020,1102,1,195,1024,1101,31,0,1016,1101,0,1,1021,1102,22,1,1004,1102,1,32,1014,1102,37,1,1019,1102,36,1,1002,1101,23,0,1003,1102,190,1,1025,1101,28,0,1009,1101,807,0,1022,1102,30,1,1015,1101,0,27,1017,1102,1,25,1012,1102,1,39,1008,1101,0,29,1007,1101,734,0,1027,1101,0,24,1006,109,28,2105,1,-4,4,187,1105,1,199,1001,64,1,64,1002,64,2,64,109,-19,1208,-9,37,63,1005,63,219,1001,64,1,64,1106,0,221,4,205,1002,64,2,64,109,20,1206,-8,233,1106,0,239,4,227,1001,64,1,64,1002,64,2,64,109,-29,2101,0,4,63,1008,63,21,63,1005,63,259,1106,0,265,4,245,1001,64,1,64,1002,64,2,64,109,-2,2107,37,4,63,1005,63,285,1001,64,1,64,1106,0,287,4,271,1002,64,2,64,109,14,1206,8,301,4,293,1105,1,305,1001,64,1,64,1002,64,2,64,109,11,21101,40,0,-6,1008,1017,40,63,1005,63,331,4,311,1001,64,1,64,1105,1,331,1002,64,2,64,109,-21,1208,1,23,63,1005,63,353,4,337,1001,64,1,64,1106,0,353,1002,64,2,64,109,26,1205,-7,371,4,359,1001,64,1,64,1106,0,371,1002,64,2,64,109,-15,21102,41,1,2,1008,1015,40,63,1005,63,395,1001,64,1,64,1106,0,397,4,377,1002,64,2,64,109,-3,2108,22,-6,63,1005,63,415,4,403,1105,1,419,1001,64,1,64,1002,64,2,64,109,-6,1201,-4,0,63,1008,63,35,63,1005,63,439,1106,0,445,4,425,1001,64,1,64,1002,64,2,64,109,14,21102,42,1,-4,1008,1014,42,63,1005,63,467,4,451,1105,1,471,1001,64,1,64,1002,64,2,64,109,-23,1201,10,0,63,1008,63,21,63,1005,63,497,4,477,1001,64,1,64,1105,1,497,1002,64,2,64,109,16,21101,43,0,2,1008,1013,42,63,1005,63,521,1001,64,1,64,1105,1,523,4,503,1002,64,2,64,109,3,21107,44,45,1,1005,1015,541,4,529,1105,1,545,1001,64,1,64,1002,64,2,64,109,-2,1205,8,561,1001,64,1,64,1106,0,563,4,551,1002,64,2,64,109,-7,1207,2,28,63,1005,63,579,1106,0,585,4,569,1001,64,1,64,1002,64,2,64,109,24,2106,0,-1,4,591,1106,0,603,1001,64,1,64,1002,64,2,64,109,-4,21108,45,45,-9,1005,1016,625,4,609,1001,64,1,64,1105,1,625,1002,64,2,64,109,-24,2101,0,0,63,1008,63,35,63,1005,63,651,4,631,1001,64,1,64,1106,0,651,1002,64,2,64,109,10,1202,-7,1,63,1008,63,24,63,1005,63,675,1001,64,1,64,1105,1,677,4,657,1002,64,2,64,109,-2,2102,1,-1,63,1008,63,41,63,1005,63,697,1105,1,703,4,683,1001,64,1,64,1002,64,2,64,109,-2,21108,46,45,3,1005,1010,723,1001,64,1,64,1105,1,725,4,709,1002,64,2,64,109,28,2106,0,-8,1106,0,743,4,731,1001,64,1,64,1002,64,2,64,109,-37,2102,1,3,63,1008,63,35,63,1005,63,769,4,749,1001,64,1,64,1105,1,769,1002,64,2,64,109,26,21107,47,46,-8,1005,1016,789,1001,64,1,64,1106,0,791,4,775,1002,64,2,64,109,7,2105,1,-8,1001,64,1,64,1106,0,809,4,797,1002,64,2,64,109,-37,1202,7,1,63,1008,63,35,63,1005,63,831,4,815,1105,1,835,1001,64,1,64,1002,64,2,64,109,18,1207,-5,30,63,1005,63,853,4,841,1106,0,857,1001,64,1,64,1002,64,2,64,109,-7,2108,37,-5,63,1005,63,873,1105,1,879,4,863,1001,64,1,64,1002,64,2,64,109,-7,2107,23,8,63,1005,63,897,4,885,1106,0,901,1001,64,1,64,4,64,99,21101,27,0,1,21102,1,915,0,1106,0,922,21201,1,12374,1,204,1,99,109,3,1207,-2,3,63,1005,63,964,21201,-2,-1,1,21101,942,0,0,1105,1,922,22102,1,1,-1,21201,-2,-3,1,21102,957,1,0,1105,1,922,22201,1,-1,-2,1106,0,968,21201,-2,0,-2,109,-3,2106,0,0
    """
  end

  def default5() do
    test(day_5_instructions(), [5])
  end

  def parse_instructions(instructions) do
    instructions
    |> String.split(",")
    |> Enum.map(fn n -> n |> String.trim() |> Integer.parse() |> elem(0) end)
  end

  # Test Functions

  @spec test(String.t()) :: {list(integer()), list(integer())}
  def test(instructions, inputs \\ [])

  def test(instructions, inputs) when is_binary(instructions) do
    instructions
    |> parse_instructions
    |> test(inputs)
  end

  def test(instructions, inputs) when is_list(instructions) do
    {input_queue, get_input_fn} = get_input_queue(inputs)
    {output_stack, output_fn} = get_output_stack()

    result =
      instructions
      |> Intcode.run(get_input: get_input_fn, output: output_fn, debug: false)

    output = get_output(output_stack)

    stop_input_queue(input_queue)
    stop_output_stack(output_stack)

    {result, output}
  end

  # Input / Output Agents

  def get_input_queue(inputs) do
    {:ok, queue} = Agent.start(fn -> inputs end)

    update_queue = fn
      [h | t] -> {h, t}
      [] -> {nil, []}
    end

    {queue, fn -> Agent.get_and_update(queue, update_queue) end}
  end

  def stop_input_queue(queue) do
    Agent.stop(queue)
  end

  def get_output_stack() do
    {:ok, stack} = Agent.start(fn -> [] end)

    {stack, fn v -> Agent.update(stack, fn stack -> [v | stack] end) end}
  end

  def get_output(stack) do
    Agent.get(stack, fn stack -> stack |> Enum.reverse() end)
  end

  def stop_output_stack(stack) do
    Agent.stop(stack)
  end
end
