import gleam/int
import gleam/list
import gleam/result
import gleam/string

fn digits(line: String) -> List(Int) {
  string.to_graphemes(line)
  |> list.filter_map(int.parse)
}

fn translate(s: String, table: List(#(String, String))) -> String {
  case table {
    [] -> s
    [#(pattern, replacement), ..rest_of_table] ->
      string.replace(each: pattern, in: s, with: replacement)
      |> translate(rest_of_table)
  }
}

fn overlapping_number_names_to_digits(line: String) -> String {
  let numbers = [
    #("one", "o1e"),
    #("two", "t2o"),
    #("three", "t3e"),
    #("four", "f4r"),
    #("five", "f5e"),
    #("six", "s6x"),
    #("seven", "s7n"),
    #("eight", "e8t"),
    #("nine", "n9e"),
  ]

  translate(line, numbers)
}

fn calibration_value(digits: List(Int)) -> Result(Int, Nil) {
  use first <- result.try(list.first(digits))
  use last <- result.try(list.last(digits))
  int.undigits([first, last], 10)
  |> result.nil_error
}

pub fn solve_part1(input: String) -> Int {
  input
  |> string.split("\n")
  |> list.map(digits)
  |> list.filter_map(calibration_value)
  |> int.sum
}

pub fn solve_part2(input: String) -> Int {
  input
  |> string.split("\n")
  |> list.map(overlapping_number_names_to_digits)
  |> list.map(digits)
  |> list.filter_map(calibration_value)
  |> int.sum
}
