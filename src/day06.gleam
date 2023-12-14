import aoc23.{par_map}
import gleam/float
import gleam/function.{curry2}
import gleam/int
import gleam/list
import gleam/pair
import gleam/result
import gleam/string
import nibble.{type Parser, drop, keep, many, spaces, whitespace}

type Race {
  Race(time: Int, record_distance: Int)
}

fn race_from_pair(pair: #(Int, Int)) -> Race {
  Race(pair.first(pair), pair.second(pair))
}

fn races_parser() -> Parser(List(Race), ctx) {
  nibble.succeed(curry2(fn(times, distances) {
    list.zip(times, distances)
    |> list.map(race_from_pair)
  }))
  |> drop(nibble.string("Time:"))
  |> drop(spaces())
  |> keep(many(nibble.int(), spaces()))
  |> drop(whitespace())
  |> drop(nibble.string("Distance:"))
  |> drop(spaces())
  |> keep(many(nibble.int(), spaces()))
}

fn parse_races(input: String) -> List(Race) {
  let assert Ok(races) = nibble.run(input, races_parser())
  races
}

fn solve_quadratic(a: Float, b: Float, c: Float) -> Result(#(Float, Float), Nil) {
  let delta = b *. b -. 4.0 *. a *. c
  let first_term = -1.0 *. b /. { 2.0 *. a }
  use sqrt <- result.try(float.square_root(delta))
  let second_term = sqrt /. { 2.0 *. a }
  Ok(#(first_term -. second_term, first_term +. second_term))
}

fn ways_to_win(race: Race) -> Int {
  // speed = button_press_duration
  // distance = speed * (time - button_press_duration)
  // button_press_duration -> x
  // distance > record_distance
  // x^2 - time * x + record_distance < 0
  // ceil(x1) <= x <= floor(x2)
  let a = 1.0
  let b = int.to_float(-race.time)
  let c = int.to_float(race.record_distance)
  let assert Ok(#(x1, x2)) = solve_quadratic(a, b, c)

  let min =
    {
      float.floor(x1)
      |> float.truncate
    } + 1

  let max =
    {
      float.ceiling(x2)
      |> float.truncate
    } - 1

  list.range(min, max)
  |> list.length
}

fn solve(races: List(Race)) -> Int {
  let assert Ok(result) =
    races
    |> par_map(ways_to_win)
    |> list.reduce(int.multiply)

  result
}

pub fn solve_part1(input: String) -> Int {
  input
  |> parse_races
  |> solve
}

pub fn solve_part2(input: String) -> Int {
  input
  |> string.replace(each: " ", with: "")
  |> parse_races
  |> solve
}
