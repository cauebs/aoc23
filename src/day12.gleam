import aoc23.{par_map}
import gleam/dict.{type Dict}
import gleam/function.{curry2}
import gleam/int
import gleam/list
import gleam/option.{type Option, None, Some}
import gleam/pair
import gleam/result
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
  cached_count_possibilities(dict.new(), None, springs, damaged_groups)
  |> pair.second
}

type CountPossibilitiesCache =
  Dict(#(List(Spring), List(Int)), Int)

fn cached_count_possibilities(
  cache: CountPossibilitiesCache,
  previous: Option(Spring),
  springs: List(Spring),
  damaged_groups: List(Int),
) -> #(CountPossibilitiesCache, Int) {
  let args = #(springs, damaged_groups)
  dict.get(cache, args)
  |> result.map(fn(result) { #(cache, result) })
  |> result.lazy_unwrap(fn() {
    let #(new_cache, value) =
      do_count_possibilities(cache, previous, springs, damaged_groups)
    #(dict.insert(new_cache, args, value), value)
  })
}

fn do_count_possibilities(
  cache: CountPossibilitiesCache,
  previous: Option(Spring),
  springs: List(Spring),
  damaged_groups: List(Int),
) -> #(CountPossibilitiesCache, Int) {
  case previous, springs, damaged_groups {
    _, [Damaged, ..], [] | _, [Damaged, ..], [0, ..] -> #(cache, 0)
    _, [], [] | _, [], [0] -> #(cache, 1)
    _, [], _ -> #(cache, 0)

    _, [Damaged, ..s], [g, ..gs] ->
      cached_count_possibilities(cache, Some(Damaged), s, [g - 1, ..gs])

    Some(Damaged), [Operational, ..s], [0, ..gs] ->
      cached_count_possibilities(cache, Some(Operational), s, gs)

    Some(Damaged), [Operational, ..], _ -> #(cache, 0)
    _, [Operational, ..s], gs ->
      cached_count_possibilities(cache, Some(Operational), s, gs)

    _, [Unknown, ..s], [] ->
      cached_count_possibilities(cache, Some(Operational), s, [])

    _, [Unknown, ..s], [0, ..gs] ->
      cached_count_possibilities(cache, Some(Operational), s, gs)

    Some(Damaged), [Unknown, ..s], [g, ..gs] ->
      cached_count_possibilities(cache, Some(Damaged), s, [g - 1, ..gs])

    _, [Unknown, ..s], [g, ..gs] -> {
      let #(new_cache, result1) =
        cached_count_possibilities(cache, Some(Operational), s, [g, ..gs])

      let #(newer_cache, result2) =
        cached_count_possibilities(new_cache, Some(Damaged), s, [g - 1, ..gs])

      let result = result1 + result2
      #(newer_cache, result)
    }
  }
}

pub fn solve_part1(input: String) -> Int {
  input
  |> string.trim
  |> string.split("\n")
  |> list.map(parse_spring_row)
  |> par_map(fn(row) { count_possibilities(row.springs, row.damaged_groups) })
  |> int.sum
}

pub fn solve_part2(input: String) -> Int {
  input
  |> string.trim
  |> string.split("\n")
  |> list.map(parse_spring_row)
  |> par_map(fn(row) {
    let springs =
      row.springs
      |> list.repeat(5)
      |> list.intersperse([Unknown])
      |> list.flatten

    let damaged_groups =
      row.damaged_groups
      |> list.repeat(5)
      |> list.flatten

    count_possibilities(springs, damaged_groups)
  })
  |> int.sum
}
