import gleam/function.{curry2}
import gleam/int
import gleam/list
import gleam/option.{type Option, None, Some}
import gleam/otp/task
import gleam/string
import nibble.{type Parser, drop, keep, many, one_of}

type Spring {
  Operational
  Damaged
  Unknown
}

type SpringRow {
  SpringRow(springs: List(Spring), damaged_groups: List(Int))
}

fn spring_parser() -> Parser(Spring, ctx) {
  one_of([
    nibble.grapheme(".")
    |> nibble.map(fn(_) { Operational }),
    nibble.grapheme("#")
    |> nibble.map(fn(_) { Damaged }),
    nibble.grapheme("?")
    |> nibble.map(fn(_) { Unknown }),
  ])
}

fn damaged_groups_parser() -> Parser(List(Int), ctx) {
  many(nibble.int(), nibble.grapheme(","))
}

fn spring_row_parser() -> Parser(SpringRow, ctx) {
  nibble.succeed(curry2(SpringRow))
  |> keep(many(spring_parser(), nibble.spaces()))
  |> drop(nibble.spaces())
  |> keep(damaged_groups_parser())
}

fn parse_spring_row(input: String) -> SpringRow {
  let assert Ok(spring_row) =
    input
    |> nibble.run(spring_row_parser())
  spring_row
}

fn count_possibilities(springs: List(Spring), damaged_groups: List(Int)) -> Int {
  do_count_possibilities(None, springs, damaged_groups)
}

fn do_count_possibilities(
  previous: Option(Spring),
  springs: List(Spring),
  damaged_groups: List(Int),
) -> Int {
  case previous, springs, damaged_groups {
    _, [Damaged, ..], [] | _, [Damaged, ..], [0, ..] -> 0
    _, [], [] | _, [], [0] -> 1
    _, [], _ -> 0

    _, [Damaged, ..s], [g, ..gs] ->
      do_count_possibilities(Some(Damaged), s, [g - 1, ..gs])
    Some(Damaged), [Operational, ..s], [0, ..gs] ->
      do_count_possibilities(Some(Operational), s, gs)
    Some(Damaged), [Operational, ..], _ -> 0
    _, [Operational, ..s], gs ->
      do_count_possibilities(Some(Operational), s, gs)

    _, [Unknown, ..s], [] -> do_count_possibilities(Some(Operational), s, [])
    _, [Unknown, ..s], [0, ..gs] ->
      do_count_possibilities(Some(Operational), s, gs)

    Some(Damaged), [Unknown, ..s], [g, ..gs] ->
      do_count_possibilities(Some(Damaged), s, [g - 1, ..gs])

    _, [Unknown, ..s], [g, ..gs] -> {
      do_count_possibilities(Some(Operational), s, [g, ..gs]) + {
        do_count_possibilities(Some(Damaged), s, [g - 1, ..gs])
      }
    }
  }
}

pub fn solve_part1(input: String) -> Int {
  input
  |> string.trim
  |> string.split("\n")
  |> list.map(parse_spring_row)
  |> list.map(fn(row) { count_possibilities(row.springs, row.damaged_groups) })
  |> int.sum
}

pub fn solve_part2(input: String) -> Int {
  input
  |> string.trim
  |> string.split("\n")
  |> list.map(parse_spring_row)
  |> list.map(fn(row) {
    let springs =
      row.springs
      |> list.repeat(5)
      |> list.intersperse([Unknown])
      |> list.flatten

    let damaged_groups =
      row.damaged_groups
      |> list.repeat(5)
      |> list.flatten

    task.async(fn() { count_possibilities(springs, damaged_groups) })
  })
  |> list.map(task.await_forever)
  |> int.sum
}
