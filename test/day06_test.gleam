import aoc23.{get_input}
import day06.{solve_part1, solve_part2}
import gleeunit/should

const example = "Time:      7  15   30
Distance:  9  40  200
"

pub fn part1_test() {
  example
  |> solve_part1
  |> should.equal(288)

  get_input(6)
  |> solve_part1
  |> should.equal(316_800)
}

pub fn part2_test() {
  example
  |> solve_part2
  |> should.equal(71_503)

  get_input(6)
  |> solve_part2
  |> should.equal(45_647_654)
}
