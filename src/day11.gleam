import aoc23.{par_map}
import gleam/string
import gleam/list
import gleam/int
import gleam/function.{identity}

type Position {
  Position(row: Int, column: Int)
}

type Image {
  Image(
    galaxies: List(Position),
    space_rows: List(Int),
    space_columns: List(Int),
  )
}

fn find_sublists_without(l: List(List(a)), x: a) -> List(Int) {
  l
  |> list.index_map(fn(i, sublist) {
    case list.all(sublist, fn(cell) { cell != x }) {
      True -> Ok(i)
      False -> Error(Nil)
    }
  })
  |> list.filter_map(identity)
}

fn parse_image(input: String) -> Image {
  let rows =
    input
    |> string.trim
    |> string.split("\n")
    |> list.map(string.to_graphemes)

  let columns = list.transpose(rows)

  let galaxies =
    rows
    |> list.index_map(fn(i, row) {
      row
      |> list.index_map(fn(j, cell) {
        case cell {
          "#" -> Ok(Position(i, j))
          _ -> Error(Nil)
        }
      })
      |> list.filter_map(identity)
    })
    |> list.flatten

  let space_rows = find_sublists_without(rows, "#")
  let space_columns = find_sublists_without(columns, "#")
  Image(galaxies, space_rows, space_columns)
}

fn distance_between_galaxies(
  g1: Position,
  g2: Position,
  space_rows: List(Int),
  space_columns: List(Int),
  expansion_factor: Int,
) -> Int {
  let dx =
    list.range(g1.row, g2.row)
    |> list.drop(1)
    |> list.map(fn(row) {
      case list.contains(space_rows, row) {
        True -> expansion_factor
        False -> 1
      }
    })
    |> int.sum

  let dy =
    list.range(g1.column, g2.column)
    |> list.drop(1)
    |> list.map(fn(column) {
      case list.contains(space_columns, column) {
        True -> expansion_factor
        False -> 1
      }
    })
    |> int.sum

  dx + dy
}

fn sum_of_distances_between_galaxy_pairs(
  image: Image,
  expansion_factor: Int,
) -> Int {
  image.galaxies
  |> list.combination_pairs
  |> par_map(fn(galaxy_pair) {
    let #(g1, g2) = galaxy_pair
    distance_between_galaxies(
      g1,
      g2,
      image.space_rows,
      image.space_columns,
      expansion_factor,
    )
  })
  |> int.sum
}

pub fn solve(input: String, expansion_factor: Int) -> Int {
  let image = parse_image(input)
  sum_of_distances_between_galaxy_pairs(image, expansion_factor)
}
