defmodule Intcode do
  @moduledoc false

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

  def advance_to_next_command(op_agent) do
    Agent.update(op_agent, fn state -> %{state | pointer: state.pointer + 4} end)
  end

  def get_op_code(op_agent) do
    %{op_map: ops, pointer: c} = Agent.get(op_agent, & &1)

    ops[c]
  end

  def get_op_params(op_agent) do
    %{op_map: ops, pointer: c} = Agent.get(op_agent, & &1)

    {ops[c + 1], ops[c + 2], ops[c + 3]}
  end

  def get_at_pointer(op_agent, pointer) do
    %{op_map: ops} = Agent.get(op_agent, & &1)

    ops[pointer]
  end

  def update_at_pointer(op_agent, pointer, value) do
    Agent.update(op_agent, fn state -> %{state | op_map: %{state.op_map | pointer => value}} end)
  end

  def get_op_list(op_agent) do
    %{op_map: ops} = Agent.get(op_agent, & &1)

    ops
    |> Map.to_list()
    |> List.keysort(0)
    |> Enum.map(fn {_i, e} -> e end)
  end

  ## Public module interface

  def run(op_list) when is_list(op_list) do
    {:ok, op_agent} = init(op_list)

    result =
      with :ok <- run_until_halt(op_agent) do
        get_op_list(op_agent)
      else
        _ -> :error
      end

    Agent.stop(op_agent)

    result
  end

  def run_until_halt(op_agent) do
    cmd = get_op_code(op_agent)

    case handle_command(op_agent, cmd) do
      :cont ->
        advance_to_next_command(op_agent)
        run_until_halt(op_agent)

      :halt ->
        :ok

      :error ->
        :error
    end
  end

  def handle_command(op_agent, 1) do
    {x, y, r} = get_op_params(op_agent)
    x_val = get_at_pointer(op_agent, x)
    y_val = get_at_pointer(op_agent, y)

    case {x_val, y_val} do
      {nil, _} -> :error

      {_, nil} -> :error

      {x_val, y_val} ->
        update_at_pointer(op_agent, r, x_val + y_val)
        :cont
    end
  end

  def handle_command(op_agent, 2) do
    {x, y, r} = get_op_params(op_agent)
    x_val = get_at_pointer(op_agent, x)
    y_val = get_at_pointer(op_agent, y)

    update_at_pointer(op_agent, r, x_val * y_val)

    :cont
  end

  def handle_command(_op_agent, 99) do
    :halt
  end
end
