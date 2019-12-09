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
  defp get_mode_from_code(2), do: :relative


  defp command(_op_agent, [99, _, _, _], opts) do
    if opts.debug, do: IO.puts(">>> halt")
    :halt
  end

  defp command(op_agent, [command, p1_mode, p2_mode, p3_mode], opts) do
    param_range = command_params_range(command)

    params =
      # Create a tuple to determine the purpose / use of each param
      [
        param_range,
        [p1_mode, p2_mode, p3_mode],
        IA.get_op_params(op_agent, param_range)
      ]
      |> Enum.zip()
      |> Enum.map(fn
        {n, :position, param} -> get_param_for_command(op_agent, command, n, param)
        {_, :immediate, param} -> param
        {n, :relative, param} -> get_relative_param_for_command(op_agent, command, n, param)
      end)

    do_command(op_agent, [command | params], opts)
  end

  def command_params_range(n), do: 1..do_command_params_range(n)

  def do_command_params_range(1), do: 3
  def do_command_params_range(2), do: 3
  def do_command_params_range(3), do: 1
  def do_command_params_range(4), do: 1
  def do_command_params_range(5), do: 2
  def do_command_params_range(6), do: 2
  def do_command_params_range(7), do: 3
  def do_command_params_range(8), do: 3
  def do_command_params_range(9), do: 1

  def get_param_for_command(_op_agent, cmd, 3, param) when cmd in [1, 2, 7, 8], do: param
  def get_param_for_command(_op_agent, cmd, 1, param) when cmd in [3], do: param
  def get_param_for_command(op_agent, _cmd, _n, position), do: IA.get_at_position(op_agent, position)

  def get_relative_param_for_command(op_agent, 3, 1, position), do: IA.get_relative_position(op_agent, position)
  def get_relative_param_for_command(op_agent, cmd, 3, position) when cmd in [1, 2, 7, 8], do: IA.get_relative_position(op_agent, position)
  def get_relative_param_for_command(op_agent, _cmd, _n, position), do: IA.get_at_relative_position(op_agent, position)

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
  defp do_command(op_agent, [3, r], %{get_input: get} = opts) do
    if opts.debug, do: IO.puts(">>> get")

    value = get.()

    IA.update_at_position(op_agent, r, value)
    IA.advance_pointer(op_agent, 2)
    :cont
  end

  # write
  defp do_command(op_agent, [4, x], %{output: put} = opts) do
    if opts.debug, do: IO.puts(">>> write")

    x |> put.()

    IA.advance_pointer(op_agent, 2)
    :cont
  end

  # jump-if-true
  defp do_command(op_agent, [5, x, r], opts) do
    if opts.debug, do: IO.puts(">>> jump-if-true")

    if x != 0 do
      IA.set_pointer(op_agent, r)
    else
      IA.advance_pointer(op_agent, 3)
    end

    :cont
  end

  # jump-if-false
  defp do_command(op_agent, [6, x, r], opts) do
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

  defp do_command(op_agent, [9, x], opts) do
    if opts.debug, do: IO.puts(">>> set relative base")

    IA.shift_relative_base(op_agent, x)
    IA.advance_pointer(op_agent, 2)
    :cont
  end
end
