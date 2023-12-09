import gleam/int
import gleam/list
import gleam/result
import gleam/string

fn parse_sequences(input: String) -> List(List(Int)) {
  input
  |> string.split("\n")
  |> list.map(fn(line) {
    line
    |> string.split(" ")
    |> list.map(int.parse)
    |> list.map(result.unwrap(_, 0))
  })
}

fn predict_next(sequence: List(Int)) -> Int {
  let differences =
    sequence
    |> list.drop(1)
    |> list.map2(sequence, with: int.subtract)

  let assert Ok(last) = list.last(sequence)

  let all_zero =
    differences
    |> list.all(fn(n) { n == 0 })

  case all_zero {
    True -> last
    False -> last + predict_next(differences)
  }
}

pub fn solve_part1(input: String) -> Int {
  input
  |> parse_sequences
  |> list.map(predict_next)
  |> int.sum
}

pub fn solve_part2(input: String) -> Int {
  input
  |> parse_sequences
  |> list.map(list.reverse)
  |> list.map(predict_next)
  |> int.sum
}
