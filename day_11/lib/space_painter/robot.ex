defmodule SpacePainter.Robot do
  defstruct [position: {0,0}, direction: :up, hull: nil, action: :paint]

  alias SpacePainter.Hull
  alias SpacePainter.Robot

  @opaque robot::pid

  def init(options \\ []) do
    Agent.start(fn -> %Robot{} end, options)
  end

  def attach_hull(robot, hull) do
    Agent.update(robot, fn robot -> %{robot | hull: hull} end)
  end

  def turn(robot, turn_direction) do
    Agent.update(robot, fn robot ->
      {position, direction} = get_next_position(robot.position, robot.direction, turn_direction)

      %{robot | position: position, direction: direction}
    end)
  end

  # Args: position, direction, turn direction,
  def get_next_position({x, y}, :up,    1), do: {{x+1, y}, :right}
  def get_next_position({x, y}, :right, 1), do: {{x, y-1}, :down}
  def get_next_position({x, y}, :down,  1), do: {{x-1, y}, :left}
  def get_next_position({x, y}, :left,  1), do: {{x, y+1}, :up}
  def get_next_position({x, y}, :up,    0), do: {{x-1, y}, :left}
  def get_next_position({x, y}, :right, 0), do: {{x, y+1}, :up}
  def get_next_position({x, y}, :down,  0), do: {{x+1, y}, :right}
  def get_next_position({x, y}, :left,  0), do: {{x, y-1}, :down}

  def get_state(robot) do
    Agent.get(robot, fn state -> state end)
  end

  def stop(robot) do
    state = Agent.get(robot, fn state -> state end)
    Agent.stop(robot)
    state
  end

  def get_camera_input_fn(robot) do
    fn ->
      Agent.get(robot, fn state ->
        Hull.camera(state.hull, state.position)
      end)
    end
  end

  def get_robot_output_fn(robot) do
    fn v ->
      Agent.update(robot, fn state ->
        case state.action do
          :paint ->
            Hull.paint(state.hull, state.position, v)
            %{state | action: :move}

          :move ->
            {position, direction} =
              get_next_position(state.position, state.direction, v)
            %{state | position: position, direction: direction, action: :paint}
        end
      end)
    end
  end
end
