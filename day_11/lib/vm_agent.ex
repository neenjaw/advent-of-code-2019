defmodule VMAgent do
  defstruct [:program, :pid, :output_pid]

  alias __MODULE__, as: VMA

  def init(program) do
    %VMA{
      program: program
    }
  end

  def start(%VMA{} = vma, vs) do
    f = fn -> Intcode.run(vma.program, get_input: get_input(), output: get_output(vma)) end

    pid = spawn(f)

    Enum.each(vs, fn v -> send(pid, v) end)

    %{vma | pid: pid}
  end

  # Input
  defp get_input() do
    fn ->
      receive do
        i ->
          i
      end
    end
  end

  # Output
  def set_output(%VMA{} = vma, pid) do
    %{vma | output_pid: pid}
  end

  defp get_output(%VMA{output_pid: opid}) do
    fn v -> send(opid, v) end
  end
end
