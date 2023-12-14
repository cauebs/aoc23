import gleam/int
import gleam/list
import gleam/pair
import gleam/string

type Pattern =
  List(List(String))

fn parse_pattern(input: String) -> Pattern {
  input
  |> string.trim
  |> string.split("\n")
  |> list.map(string.to_graphemes)
}

fn parse_patterns(input: String) -> List(Pattern) {
  input
  |> string.trim
  |> string.split("\n\n")
  |> list.map(parse_pattern)
}

fn find_horizontal_reflection_line(
  pattern: Pattern,
  comparison_method: fn(Pattern, Pattern) -> Bool,
) {
  list.range(1, list.length(pattern) - 1)
  |> list.find(fn(index) {
    let #(first_half_of_rows, second_half_of_rows) =
      list.split(pattern, at: index)

    comparison_method(list.reverse(first_half_of_rows), second_half_of_rows)
  })
}

fn solve(input: String, comparison_method: fn(Pattern, Pattern) -> Bool) -> Int {
  let patterns = parse_patterns(input)

  let horizontal =
    patterns
    |> list.filter_map(find_horizontal_reflection_line(_, comparison_method))
    |> int.sum

  let vertical =
    patterns
    |> list.map(list.transpose)
    |> list.filter_map(find_horizontal_reflection_line(_, comparison_method))
    |> int.sum

  horizontal * 100 + vertical
}

fn normal_comparison(rows1: Pattern, rows2: Pattern) -> Bool {
  list.zip(rows1, rows2)
  |> list.all(fn(p) { pair.first(p) == pair.second(p) })
}

pub fn solve_part1(input: String) -> Int {
  solve(input, normal_comparison)
}

fn comparison_with_smudge(rows1: Pattern, rows2: Pattern) -> Bool {
  list.zip(rows1, rows2)
  |> list.map(fn(rows) {
    let #(row_from_first_half, row_from_second_half) = rows
    list.zip(row_from_first_half, row_from_second_half)
    |> list.filter(fn(p) { pair.first(p) != pair.second(p) })
    |> list.length
  })
  |> int.sum == 1
}

pub fn solve_part2(input: String) -> Int {
  solve(input, comparison_with_smudge)
}
