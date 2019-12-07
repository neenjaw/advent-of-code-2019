defmodule PhaseAmplifier do
  def permutations([]), do: [[]]
  def permutations(list), do: for elem <- list, rest <- permutations(list--[elem]), do: [elem|rest]

  def sequence(program, [a, b, c, d, e], v \\ 0) do
    {_, [v0]} = VMRunner.test(program, [a,v])
    {_, [v1]} = VMRunner.test(program, [b,v0])
    {_, [v2]} = VMRunner.test(program, [c,v1])
    {_, [v3]} = VMRunner.test(program, [d,v2])
    {_, [v4]} = VMRunner.test(program, [e,v3])

    v4
  end

  def find_max_sequence(program) do
    0..4
    |>Enum.to_list()
    |>permutations()
    |>Enum.map(fn p -> {p, sequence(program, p)} end)
    |>Enum.max_by(fn {_p, n} -> n end)
  end

  # Feedback version

  def feedback_sequence(program, [a,b,c,d,e], v \\0) do
    # get instructions
    program =
      VMRunner.parse_instructions(program)

    # get vms
    [vm0, vm1, vm2, vm3, vm4] =
      0..4
      |> Enum.map(fn _ -> VMAgent.init(program) end)

    # connect output of vm to the next vm in the cycle
    vm4 = vm4 |> VMAgent.set_output(self()) |> VMAgent.start([e])
    vm3 = vm3 |> VMAgent.set_output(vm4.pid) |> VMAgent.start([d])
    vm2 = vm2 |> VMAgent.set_output(vm3.pid) |> VMAgent.start([c])
    vm1 = vm1 |> VMAgent.set_output(vm2.pid) |> VMAgent.start([b])
    vm0 = vm0 |> VMAgent.set_output(vm1.pid) |> VMAgent.start([a, v])

    receive_result_or_loop(vm0.pid)
  end

  def receive_result_or_loop(pid) do
    receive do
      i ->
        if not Process.alive?(pid) do
          i
        else
          send(pid, i)
          receive_result_or_loop(pid)
        end
    end

  end

  def find_max_feedback_amplification(program) do
    5..9
    |>Enum.to_list()
    |>permutations()
    |>Enum.map(fn p -> {p, feedback_sequence(program, p)} end)
    |>Enum.max_by(fn {_p, n} -> n end)
  end
end
