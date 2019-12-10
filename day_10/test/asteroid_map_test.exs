defmodule AsteroidMapTest do
  use ExUnit.Case

  @map1 """
  .#..#
  .....
  #####
  ....#
  ...##
  """

  @map2 """
  ......#.#.
  #..#.#....
  ..#######.
  .#.#.###..
  .#..#.....
  ..#....#.#
  #..#....#.
  .##.#..###
  ##...#..#.
  .#....####
  """

  @map3 """
  #.#...#.#.
  .###....#.
  .#....#...
  ##.#.#.#.#
  ....#.#.#.
  .##..###.#
  ..#...##..
  ..##....##
  ......#...
  .####.###.
  """

  @map4 """
  .#..#..###
  ####.###.#
  ....###.#.
  ..###.##.#
  ##.##.#.#.
  ....###..#
  ..#.#..#.#
  #..#.#.###
  .##...##.#
  .....#.#..
  """

  @map5 """
  .#..##.###...#######
  ##.############..##.
  .#.######.########.#
  .###.#######.####.#.
  #####.##.#.##.###.##
  ..#####..#.#########
  ####################
  #.####....###.#.#.##
  ##.#################
  #####.##.###..####..
  ..######..##.#######
  ####.##.####...##..#
  .#####..#.######.###
  ##...#.##########...
  #.##########.#######
  .####.#.###.###.#.##
  ....##.##.###..#####
  .#.#.###########.###
  #.#.#.#####.####.###
  ###.##.####.##.#..##
  """

  @part1 """
  ...###.#########.####
  .######.###.###.##...
  ####.########.#####.#
  ########.####.##.###.
  ####..#.####.#.#.##..
  #.################.##
  ..######.##.##.#####.
  #.####.#####.###.#.##
  #####.#########.#####
  #####.##..##..#.#####
  ##.######....########
  .#######.#.#########.
  .#.##.#.#.#.##.###.##
  ######...####.#.#.###
  ###############.#.###
  #.#####.##..###.##.#.
  ##..##..###.#.#######
  #..#..########.#.##..
  #.#.######.##.##...##
  .#.##.#####.#..#####.
  #.#.##########..#.##.
  """

  test "map 1 solve" do
    assert CeresMonitor.solve(@map1) == {{3, 4}, 8}
  end

  test "map 2 solve" do
    assert CeresMonitor.solve(@map2) == {{5, 8}, 33}
  end

  test "map 3 solve" do
    assert CeresMonitor.solve(@map3) == {{1, 2}, 35}
  end

  test "map 4 solve" do
    assert CeresMonitor.solve(@map4) == {{6, 3}, 41}
  end

  test "map 5 solve" do
    assert CeresMonitor.solve(@map5) == {{11, 13}, 210}
  end

  test "part1" do
    assert CeresMonitor.solve(@part1) == {{11, 13}, 227}
  end

  test "destruction" do
    map = @map5
    c = {11, 13}
    result = CeresMonitor.destroy_asteroids(map, c)
    record = result.meta.destroy_record

    assert Map.get(record, 1) ==   {11, 12}
    assert Map.get(record, 2) ==   {12, 1}
    assert Map.get(record, 3) ==   {12, 2}
    assert Map.get(record, 10) ==  {12, 8}
    assert Map.get(record, 20) ==  {16, 0}
    assert Map.get(record, 50) ==  {16, 9}
    # assert Map.get(record, 100) == {10, 16}
    assert Map.get(record, 199) == {9, 6}
    assert Map.get(record, 200) == {8, 2}
    assert Map.get(record, 201) == {10, 9}
    assert Map.get(record, 299) == {11, 1}
  end

  test "part 2" do
    map = @part1
    c = {11, 13}
    result = CeresMonitor.destroy_asteroids(map, c)
    record = result.meta.destroy_record

    Map.get(record, 200) |> IO.inspect(label: "147")
  end
end
