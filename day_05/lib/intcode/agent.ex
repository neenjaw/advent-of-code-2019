defmodule Intcode.Agent do
  def init(op_list) when is_list(op_list) do
    op_map =
      op_list
      |> Enum.with_index()
      |> Enum.map(fn {e, i} -> {i, e} end)
      |> Enum.into(%{})

    state = %{
      op_map: op_map,
      pointer: 0,
      n: length(op_list)
    }

    Agent.start_link(fn -> state end)
  end

  def advance_to_next_command(op_agent, cmd \\ 0) do
    n = get_command_pointer_offset(cmd)

    Agent.update(op_agent, fn state -> %{state | pointer: state.pointer + n} end)
  end

  defp get_command_pointer_offset(cmd) do
    case cmd do
      0 ->
        4

      1 ->
        4

      2 ->
        4

      3 ->
        2

      4 ->
        2

      5 ->
        3

      6 ->
        3

      7 ->
        4

      8 ->
        4

      c ->
        [e, d | _] =
          c
          |> Integer.digits()
          |> Enum.reverse()

        [d, e]
        |> Integer.undigits()
        |> get_command_pointer_offset()
    end
  end

  def get_op_code(op_agent) do
    %{op_map: ops, pointer: c} = Agent.get(op_agent, & &1)

    ops[c]
  end

  def get_op_params(op_agent, n \\ 3) do
    %{op_map: ops, pointer: c} = Agent.get(op_agent, & &1)

    1..n
    |> Enum.map(fn i -> ops[c + i] end)
    |> List.to_tuple()
  end

  def get_at_position(op_agent, position) do
    %{op_map: ops} = Agent.get(op_agent, & &1)

    ops[position]
  end

  def update_at_position(op_agent, pointer, value) do
    Agent.update(op_agent, fn state -> %{state | op_map: %{state.op_map | pointer => value}} end)
  end

  def set_pointer(op_agent, new_pointer) do
    Agent.update(op_agent, fn state -> %{state | pointer: new_pointer} end)
  end

  def get_op_list(op_agent) do
    %{op_map: ops} = Agent.get(op_agent, & &1)

    ops
    |> Map.to_list()
    |> List.keysort(0)
    |> Enum.map(fn {_i, e} -> e end)
  end
end
