defmodule Intcode do
  @moduledoc false

  alias Intcode.Agent, as: IA

  ## Public module interface

  def run(op_list, opts \\ []) when is_list(op_list) do
    testing = Keyword.get(opts, :testing, false)

    opts =
      unless testing do
        opts
      else
        init_test_input(opts)
      end

    {:ok, op_agent} = IA.init(op_list)

    result =
      with :ok <- run_until_halt(op_agent, opts) do
        IA.get_op_list(op_agent)
      else
        _ -> :error
      end

    Agent.stop(op_agent)
    if testing, do: Keyword.get(opts, :test_input) |> Agent.stop()

    result
  end

  def run_until_halt(op_agent, opts) do
    cmd = IA.get_op_code(op_agent)

    case handle_command(op_agent, cmd, opts) do
      :cont ->
        IA.advance_to_next_command(op_agent, cmd)
        run_until_halt(op_agent, opts)

      :jump ->
        run_until_halt(op_agent, opts)

      :halt ->
        :ok

      :error ->
        :error
    end
  end

  def handle_command(op_agent, command, mode_opts \\ [])

  # add
  def handle_command(op_agent, 1, mode_opts) do
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
  def handle_command(op_agent, 2, mode_opts) do
    {x, y, r} = IA.get_op_params(op_agent)
    x_val = get_parameter(op_agent, mode_opts, :first, x)
    y_val = get_parameter(op_agent, mode_opts, :second, y)

    IA.update_at_position(op_agent, r, x_val * y_val)

    :cont
  end

  # get input
  def handle_command(op_agent, 3, mode_opts) do
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
  def handle_command(op_agent, 4, _mode_opts) do
    {position} = IA.get_op_params(op_agent, 1)
    value = IA.get_at_position(op_agent, position)

    value |> inspect() |> IO.puts()

    :cont
  end

  # jump-if-true
  def handle_command(op_agent, 5, mode_opts) do
    {x, r} = IA.get_op_params(op_agent, 2)
    x_val = get_parameter(op_agent, mode_opts, :first, x)

    if x_val != 0 do
      IA.set_pointer(op_agent, r)
      :jump
    else
      :cont
    end
  end

  # jump-if-false
  def handle_command(op_agent, 6, mode_opts) do
    {x, r} = IA.get_op_params(op_agent, 2)
    x_val = get_parameter(op_agent, mode_opts, :first, x)

    if x_val == 0 do
      IA.set_pointer(op_agent, r)
      :jump
    else
      :cont
    end
  end

  # less than
  def handle_command(op_agent, 7, mode_opts) do
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
  def handle_command(op_agent, 8, mode_opts) do
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

  def handle_command(_op_agent, 99, _mode_opts) do
    :halt
  end

  def handle_command(op_agent, command_code, mode_opts) do
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
      |> add_param_mode(:first, c)
      |> add_param_mode(:second, b)
      |> add_param_mode(:third, a)

    handle_command(op_agent, command, mode_opts)
  end

  def add_param_mode(kw, param, v) do
    mode =
      case v do
        1 -> :immediate
        0 -> :position
      end

    Keyword.put(kw, param, mode)
  end

  def get_param_mode(kw, param) do
    Keyword.get(kw, param, :position)
  end

  def get_parameter(op_agent, mode_opts, param, p) do
    mode = get_param_mode(mode_opts, param)

    case mode do
      :position -> IA.get_at_position(op_agent, p)
      :immediate -> p
    end
  end

  ###
  # Testing functions
  def init_test_input(opts) do
    {_, opts} =
      Keyword.get_and_update(opts, :test_input, fn input ->
        input = if input == nil, do: [], else: input

        {:ok, test_input} = Agent.start(fn -> input end)

        {input, test_input}
      end)

    opts
  end

  def get_test_input(opts) do
    {input, _} =
      Keyword.get_and_update!(opts, :test_input, fn test_input ->
        v = Agent.get_and_update(test_input, fn [v | r] -> {v, r} end)
        {v, test_input}
      end)

    input
  end
end
