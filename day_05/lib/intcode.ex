defmodule Intcode do
  @moduledoc false

  alias Intcode.Agent, as: IA
  alias Intcode.Default, as: ID

  @defaults [
    {:get_input, &ID.get_input/0},
    {:output, &ID.output/1},
    {:debug, false}
  ]

  ## Public module interface

  def run(op_list, opts \\ []) when is_list(op_list) do
    opts_map = Keyword.merge(@defaults, opts) |> Enum.into(%{})

    # start state agent
    {:ok, op_agent} = IA.init(op_list)

    result =
      with :ok <- compute(op_agent, opts_map) do
        IA.get_op_list(op_agent)
      else
        _ -> :error
      end

    Agent.stop(op_agent)

    result
  end

  defp compute(op_agent, opts) do
    cmd = IA.get_op_code(op_agent)

    case handle_command(op_agent, cmd, opts) do
      :cont ->
        compute(op_agent, opts)

      :halt ->
        :ok

      :error ->
        :error
    end
  end

  defp handle_command(op_agent, command_code, opts) do
    [e, d, c, b, a | _] =
      command_code
      |> Integer.digits()
      |> Enum.reverse()
      |> Kernel.++(List.duplicate(0, 4))

    command =
      [d, e]
      |> Integer.undigits()

    [p1_mode, p2_mode, p3_mode] =
      [c, b, a]
      |> Enum.map(&get_mode_from_code/1)

    command(op_agent, [command, p1_mode, p2_mode, p3_mode], opts)
  end

  defp get_mode_from_code(0), do: :position
  defp get_mode_from_code(1), do: :immediate

  defp command(op_agent, [command, p1_mode, p2_mode, p3_mode], opts) do
    [p1, p2, p3] =
      # Create a tuple to determine the purpose / use of each param
      [
        List.duplicate(command, 3),
        1..3,
        [p1_mode, p2_mode, p3_mode],
        IA.get_op_params(op_agent)
      ]
      |> Enum.zip()
      |> Enum.map(fn
        {cmd, n, :position, param} -> get_param_for_command(op_agent, cmd, n, param)
        {_cmd, _, :immediate, param} -> param
      end)

    do_command(op_agent, [command, p1, p2, p3], opts)
  end

  def get_param_for_command(_op_agent, cmd, 3, param) when cmd in [1, 2, 7, 8], do: param
  # def get_param_for_command(_op_agent, cmd, 2, param) when cmd in [5, 6], do: param
  def get_param_for_command(_op_agent, cmd, 1, param) when cmd in [3], do: param
  def get_param_for_command(op_agent, _cmd, _n, position), do: IA.get_at_position(op_agent, position)

  # add
  defp do_command(op_agent, [1, x, y, r], opts) do
    if opts.debug, do: IO.puts(">>> add")

    case {x, y} do
      {nil, _} ->
        :error

      {_, nil} ->
        :error

      {x, y} ->
        IA.update_at_position(op_agent, r, x + y)
        IA.advance_pointer(op_agent, 4)
        :cont
    end
  end

  # multiply
  defp do_command(op_agent, [2, x, y, r], opts) do
    if opts.debug, do: IO.puts(">>> mult")

    IA.update_at_position(op_agent, r, x * y)

    IA.advance_pointer(op_agent, 4)
    :cont
  end

  # get input
  defp do_command(op_agent, [3, r, _, _], %{get_input: get} = opts) do
    if opts.debug, do: IO.puts(">>> get")

    value = get.()

    IA.update_at_position(op_agent, r, value)
    IA.advance_pointer(op_agent, 2)
    :cont
  end

  # write
  defp do_command(op_agent, [4, x, _, _], %{output: put} = opts) do
    if opts.debug, do: IO.puts(">>> write")

    x |> put.()

    IA.advance_pointer(op_agent, 2)
    :cont
  end

  # jump-if-true
  defp do_command(op_agent, [5, x, r, _], opts) do
    if opts.debug, do: IO.puts(">>> jump-if-true")

    if x != 0 do
      IA.set_pointer(op_agent, r)
    else
      IA.advance_pointer(op_agent, 3)
    end

    :cont
  end

  # jump-if-false
  defp do_command(op_agent, [6, x, r, _], opts) do
    if opts.debug, do: IO.puts(">>> jump-if-false")

    if x == 0 do
      IA.set_pointer(op_agent, r)
    else
      IA.advance_pointer(op_agent, 3)
    end

    :cont
  end

  # less than
  defp do_command(op_agent, [7, x, y, r], opts) do
    if opts.debug, do: IO.puts(">>> less than")

    if x < y do
      IA.update_at_position(op_agent, r, 1)
    else
      IA.update_at_position(op_agent, r, 0)
    end

    IA.advance_pointer(op_agent, 4)
    :cont
  end

  # equal to
  defp do_command(op_agent, [8, x, y, r], opts) do
    if opts.debug, do: IO.puts(">>> equal")

    if x == y do
      IA.update_at_position(op_agent, r, 1)
    else
      IA.update_at_position(op_agent, r, 0)
    end

    IA.advance_pointer(op_agent, 4)
    :cont
  end

  defp do_command(_op_agent, [99, _, _, _], opts) do
    if opts.debug, do: IO.puts(">>> halt")

    :halt
  end
end
