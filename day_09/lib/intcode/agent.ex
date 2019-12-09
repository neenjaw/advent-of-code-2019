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
      n: length(op_list),
      relative_base: 0
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

  def get_op_params(op_agent, r) do
    %{pointer: c} = Agent.get(op_agent, & &1)

    r
    |> Enum.map(fn i -> get_at_position(op_agent, c + i) end)
  end

  def get_relative_position(op_agent, position) do
    %{op_map: _ops, relative_base: b} = Agent.get(op_agent, & &1)

    position + b
  end

  def get_at_position(op_agent, position) do
    do_get_at_position(op_agent, position)
  end

  def get_at_relative_position(op_agent, position) do
    do_get_at_position(op_agent, position, relative: true)
  end

  defp do_get_at_position(op_agent, position, opts \\ []) do
    %{op_map: ops, relative_base: b} = Agent.get(op_agent, & &1)

    offset =
      if opts[:relative] do
        position + b
      else
        position
      end

    case ops[offset] do
      nil ->
        update_at_position(op_agent, offset, 0)
        0

      x -> x
    end
  end

  def update_at_position(op_agent, pointer, value) do
    Agent.update(op_agent, fn state ->
      %{state | op_map: Map.put(state.op_map, pointer, value)}
    end)
  end

  def set_pointer(op_agent, new_pointer) do
    Agent.update(op_agent, fn state -> %{state | pointer: new_pointer} end)
  end

  def shift_relative_base(op_agent, shift) do
    Agent.update(op_agent, fn state -> %{state | relative_base: state.relative_base + shift} end)
  end

  def get_op_list(op_agent) do
    %{op_map: ops} = Agent.get(op_agent, & &1)

    indices =
      ops
      |> Map.keys()
      |> Enum.sort()

    first = indices |> List.first()
    last = indices |> List.last()

    first..last
    |> Enum.map(fn i ->
      if ops[i], do: ops[i], else: 0
    end)
  end
end
