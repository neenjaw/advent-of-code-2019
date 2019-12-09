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

  def advance_pointer(op_agent, n \\ 0) do
    Agent.update(op_agent, fn state -> %{state | pointer: state.pointer + n} end)
  end

  def get_op_code(op_agent) do
    %{op_map: ops, pointer: c} = Agent.get(op_agent, & &1)

    ops[c]
  end

  def get_op_params(op_agent) do
    %{op_map: ops, pointer: c} = Agent.get(op_agent, & &1)

    1..3
    |> Enum.map(fn i -> ops[c + i] end)
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
