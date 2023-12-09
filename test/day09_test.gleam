import aoc23.{get_input}
import day09.{solve_part1, solve_part2}
import gleeunit/should

const example = "0 3 6 9 12 15
1 3 6 10 15 21
10 13 16 21 30 45"

pub fn part1_test() {
  example
  |> solve_part1
  |> should.equal(114)

  get_input(9)
  |> solve_part1
  |> should.equal(1_684_566_095)
}

pub fn part2_test() {
  example
  |> solve_part2
  |> should.equal(2)

  get_input(9)
  |> solve_part2
  |> should.equal(1136)
}
