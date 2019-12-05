defmodule Intcode do
  @moduledoc false

  alias Intcode.Agent, as: IA

  ## Public module interface

  def run(op_list, opts \\ []) when is_list(op_list) do
    cond do
      Keyword.get(opts, :testing, false) -> do_run_wrap_testing(op_list, &do_run/2, opts)
      true -> do_run(op_list, opts)
    end
  end

  def do_run(op_list, opts) do
    {:ok, op_agent} = IA.init(op_list)

    result =
      with :ok <- compute(op_agent, opts) do
        IA.get_op_list(op_agent)
      else
        _ -> :error
      end

    Agent.stop(op_agent)

    result
  end

  def do_run_wrap_testing(op_list, runner, opts) do
    opts = init_test_input(opts)
    result = runner.(op_list, opts)

    stop_test_input(opts)

    result
  end

  defp compute(op_agent, opts) do
    cmd = IA.get_op_code(op_agent)

    case handle_command(op_agent, cmd, opts) do
      :cont ->
        IA.advance_to_next_command(op_agent, cmd)
        compute(op_agent, opts)

      :jump ->
        compute(op_agent, opts)

      :halt ->
        :ok

      :error ->
        :error
    end
  end

  # add
  defp handle_command(op_agent, 1, mode_opts) do
    {x, y, r} = IA.get_op_params(op_agent)
    x_val = get_parameter(op_agent, mode_opts, :first, x)
    y_val = get_parameter(op_agent, mode_opts, :second, y)

    case {x_val, y_val} do
      {nil, _} ->
        :error

      {_, nil} ->
        :error

      {x_val, y_val} ->
        IA.update_at_position(op_agent, r, x_val + y_val)
        :cont
    end
  end

  # multiply
  defp handle_command(op_agent, 2, mode_opts) do
    {x, y, r} = IA.get_op_params(op_agent)
    x_val = get_parameter(op_agent, mode_opts, :first, x)
    y_val = get_parameter(op_agent, mode_opts, :second, y)

    IA.update_at_position(op_agent, r, x_val * y_val)

    :cont
  end

  # get input
  defp handle_command(op_agent, 3, mode_opts) do
    input =
      unless Keyword.get(mode_opts, :testing, false) do
        IO.gets("integer input? ")
      else
        get_test_input(mode_opts)
      end

    {value, _} = input |> Integer.parse()
    {position} = IA.get_op_params(op_agent, 1)

    IA.update_at_position(op_agent, position, value)

    :cont
  end

  # write
  defp handle_command(op_agent, 4, mode_opts) do
    {r} = IA.get_op_params(op_agent, 1)
    value = get_parameter(op_agent, mode_opts, :first, r)

    value |> inspect() |> IO.puts()

    :cont
  end

  # jump-if-true
  defp handle_command(op_agent, 5, mode_opts) do
    {x, r} = IA.get_op_params(op_agent, 2)
    x_val = get_parameter(op_agent, mode_opts, :first, x)
    r_val = get_parameter(op_agent, mode_opts, :second, r)

    if x_val != 0 do
      IA.set_pointer(op_agent, r_val)
      :jump
    else
      :cont
    end
  end

  # jump-if-false
  defp handle_command(op_agent, 6, mode_opts) do
    {x, r} = IA.get_op_params(op_agent, 2)
    x_val = get_parameter(op_agent, mode_opts, :first, x)
    r_val = get_parameter(op_agent, mode_opts, :second, r)

    if x_val == 0 do
      IA.set_pointer(op_agent, r_val)
      :jump
    else
      :cont
    end
  end

  # less than
  defp handle_command(op_agent, 7, mode_opts) do
    {x, y, r} = IA.get_op_params(op_agent, 3)
    x_val = get_parameter(op_agent, mode_opts, :first, x)
    y_val = get_parameter(op_agent, mode_opts, :second, y)

    if x_val < y_val do
      IA.update_at_position(op_agent, r, 1)
    else
      IA.update_at_position(op_agent, r, 0)
    end

    :cont
  end

  # equal to
  defp handle_command(op_agent, 8, mode_opts) do
    {x, y, r} = IA.get_op_params(op_agent, 3)
    x_val = get_parameter(op_agent, mode_opts, :first, x)
    y_val = get_parameter(op_agent, mode_opts, :second, y)

    if x_val == y_val do
      IA.update_at_position(op_agent, r, 1)
    else
      IA.update_at_position(op_agent, r, 0)
    end

    :cont
  end

  defp handle_command(_op_agent, 99, _mode_opts) do
    :halt
  end

  defp handle_command(op_agent, command_code, mode_opts) do
    [e, d, c, b, a | _] =
      command_code
      |> Integer.digits()
      |> Enum.reverse()
      |> Kernel.++(List.duplicate(0, 4))

    command =
      [d, e]
      |> Integer.undigits()

    mode_opts =
      mode_opts
      |> add_parameter_mode(:first, c)
      |> add_parameter_mode(:second, b)
      |> add_parameter_mode(:third, a)

    handle_command(op_agent, command, mode_opts)
  end

  defp add_parameter_mode(kw, param, v) do
    mode =
      case v do
        1 -> :immediate
        0 -> :position
      end

    Keyword.put(kw, param, mode)
  end

  defp get_parameter_mode(kw, param) do
    Keyword.get(kw, param, :position)
  end

  defp get_parameter(op_agent, mode_opts, param, p) do
    mode = get_parameter_mode(mode_opts, param)

    case mode do
      :position -> IA.get_at_position(op_agent, p)
      :immediate -> p
    end
  end

  ###
  # Testing functions
  defp init_test_input(opts) do
    {_, opts} =
      Keyword.get_and_update(opts, :test_input, fn input ->
        input = if input == nil, do: [], else: input

        {:ok, test_input} = Agent.start(fn -> input end)

        {input, test_input}
      end)

    opts
  end

  defp stop_test_input(opts) do
    Keyword.get(opts, :test_input) |> Agent.stop()
  end

  defp get_test_input(opts) do
    {input, _} =
      Keyword.get_and_update!(opts, :test_input, fn test_input ->
        v = Agent.get_and_update(test_input, fn [v | r] -> {v, r} end)
        {v, test_input}
      end)

    input
  end
end
