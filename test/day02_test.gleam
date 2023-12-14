import aoc23.{get_input}
import day02.{solve_part1, solve_part2}
import gleam/dict
import gleeunit/should

const example = "Game 1: 3 blue, 4 red; 1 red, 2 green, 6 blue; 2 green
Game 2: 1 blue, 2 green; 3 green, 4 blue, 1 red; 1 green, 1 blue
Game 3: 8 green, 6 blue, 20 red; 5 blue, 4 red, 13 green; 5 green, 1 red
Game 4: 1 green, 3 red, 6 blue; 3 green, 6 red; 3 green, 15 blue, 14 red
Game 5: 6 red, 1 blue, 3 green; 2 blue, 1 red, 2 green"

pub fn part1_test() {
  let limits = dict.from_list([#("red", 12), #("green", 13), #("blue", 14)])

  example
  |> solve_part1(limits)
  |> should.equal(8)

  get_input(2)
  |> solve_part1(limits)
  |> should.equal(3099)
}

pub fn part2_test() {
  example
  |> solve_part2()
  |> should.equal(2286)

  get_input(2)
  |> solve_part2()
  |> should.equal(72_970)
}

pub fn main() {
  part1_test()
  part2_test()
}
