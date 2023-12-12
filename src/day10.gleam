import gleam/dict.{type Dict}
import gleam/int
import gleam/iterator
import gleam/list
import gleam/result
import gleam/string

type Cell =
  String

type Position {
  Position(row: Int, column: Int)
}

type Maze =
  Dict(Position, Cell)

fn parse_maze(input: String) -> Maze {
  input
  |> string.trim
  |> string.split("\n")
  |> list.index_map(fn(i, line) {
    line
    |> string.to_graphemes
    |> list.index_map(fn(j, cell) { #(Position(i, j), cell) })
  })
  |> list.flatten
  |> dict.from_list
}

fn find_start(maze: Maze) -> Position {
  let assert Ok(pos) =
    maze
    |> dict.filter(fn(_pos, cell) { cell == "S" })
    |> dict.keys
    |> list.first

  pos
}

type Direction {
  East
  North
  West
  South
}

fn move(from pos: Position, in dir: Direction) -> Position {
  case dir {
    East -> Position(..pos, column: pos.column + 1)
    North -> Position(..pos, row: pos.row - 1)
    West -> Position(..pos, column: pos.column - 1)
    South -> Position(..pos, row: pos.row + 1)
  }
}

fn adjacent_positions(pos: Position) -> List(#(Direction, Position)) {
  [East, North, West, South]
  |> list.map(fn(dir) { #(dir, move(from: pos, in: dir)) })
}

fn next_direction(
  through pipe: Cell,
  towards dir: Direction,
) -> Result(Direction, Nil) {
  case pipe, dir {
    "|", _ -> Ok(dir)
    "-", _ -> Ok(dir)
    "L", South -> Ok(East)
    "L", West -> Ok(North)
    "J", South -> Ok(West)
    "J", East -> Ok(North)
    "7", East -> Ok(South)
    "7", North -> Ok(West)
    "F", West -> Ok(South)
    "F", North -> Ok(East)
    _, _ -> Error(Nil)
  }
}

fn loop_cells_until_start(
  pos: Position,
  dir: Direction,
  maze: Maze,
) -> Result(List(Position), Nil) {
  use pipe <- result.try(dict.get(maze, pos))

  use next_dir <- result.try(next_direction(through: pipe, towards: dir))
  let next_pos = move(from: pos, in: next_dir)

  case dict.get(maze, next_pos) {
    Ok("S") -> Ok([pos, next_pos])
    Ok(_) ->
      loop_cells_until_start(next_pos, next_dir, maze)
      |> result.map(fn(additional_steps) { [pos, ..additional_steps] })
    Error(err) -> Error(err)
  }
}

fn get_loop_cells(from pos: Position, in maze: Maze) -> List(Position) {
  let assert Ok(loop_cells) =
    pos
    |> adjacent_positions
    |> list.filter_map(fn(dir_and_pos) {
      let #(dir, pos) = dir_and_pos
      loop_cells_until_start(pos, dir, maze)
    })
    |> list.first

  loop_cells
}

fn steps_to_farthest_pos(loop_cells: List(Position)) -> Int {
  list.length(loop_cells) / 2
}

pub fn solve_part1(input: String) -> Int {
  let maze = parse_maze(input)
  let start = find_start(maze)
  get_loop_cells(from: start, in: maze)
  |> steps_to_farthest_pos
}

fn direction_between(
  from pos1: Position,
  to pos2: Position,
) -> Result(Direction, Nil) {
  case pos2.row - pos1.row, pos2.column - pos1.column {
    1, 0 -> Ok(South)
    0, 1 -> Ok(East)
    -1, 0 -> Ok(North)
    0, -1 -> Ok(West)
    _, _ -> Error(Nil)
  }
}

fn replace_start_with_pipe(
  maze: Maze,
  start: Position,
  loop_cells: List(Position),
) -> Maze {
  let assert Ok(first) = list.first(loop_cells)
  let assert Ok(last) =
    loop_cells
    |> list.filter(fn(pos) { pos != start })
    |> list.last()

  let assert Ok(from) = direction_between(start, last)
  let assert Ok(to) = direction_between(start, first)

  let pipe = case from, to {
    East, North -> "L"
    East, West -> "-"
    East, South -> "F"
    North, East -> "L"
    North, West -> "J"
    North, South -> "|"
    West, East -> "-"
    West, North -> "J"
    West, South -> "7"
    South, East -> "F"
    South, North -> "|"
    South, West -> "7"
  }

  maze
  |> dict.insert(start, pipe)
}

fn collides(ray_dir: Direction, cell: Cell) -> Bool {
  case ray_dir {
    East ->
      case cell {
        "|" | "L" | "J" -> True
        _ -> False
      }
    North ->
      case cell {
        "-" | "F" | "L" -> True
        _ -> False
      }
    West ->
      case cell {
        "|" | "F" | "7" -> True
        _ -> False
      }
    South ->
      case cell {
        "-" | "J" | "7" -> True
        _ -> False
      }
    _ -> False
  }
}

fn raycast_count_cells_inside_loop(
  pos: Position,
  dir: Direction,
  was_inside: Bool,
  cells_inside: Int,
  loop_cells: List(Position),
  maze: Maze,
) -> Int {
  case dict.get(maze, pos) {
    Error(_) -> cells_inside
    Ok(cell) -> {
      let is_over_loop = list.contains(loop_cells, pos)
      let next_pos = move(pos, dir)

      let is_inside = case collides(dir, cell) && is_over_loop {
        True -> !was_inside
        _ -> was_inside
      }

      let cells_inside = case is_inside, is_over_loop {
        True, False -> cells_inside + 1
        _, _ -> cells_inside
      }

      raycast_count_cells_inside_loop(
        next_pos,
        dir,
        is_inside,
        cells_inside,
        loop_cells,
        maze,
      )
    }
  }
}

fn count_cells_inside_loop(
  start: Position,
  dir: Direction,
  loop_cells: List(Position),
  maze: Maze,
) -> Int {
  raycast_count_cells_inside_loop(start, dir, False, 0, loop_cells, maze)
}

pub fn solve_part2(input: String) -> Int {
  let maze = parse_maze(input)
  let start = find_start(maze)
  let loop_cells = get_loop_cells(from: start, in: maze)

  let maze = replace_start_with_pipe(maze, start, loop_cells)

  iterator.iterate(0, fn(i) { i + 1 })
  |> iterator.map(Position(_, 0))
  |> iterator.take_while(dict.has_key(maze, _))
  |> iterator.map(count_cells_inside_loop(_, East, loop_cells, maze))
  |> iterator.to_list
  |> int.sum
}
