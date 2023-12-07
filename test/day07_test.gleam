import aoc23.{get_input}
import day07.{solve_part1, solve_part2}
import gleeunit/should

const example = "32T3K 765
T55J5 684
KK677 28
KTJJT 220
QQQJA 483"

pub fn part1_test() {
  example
  |> solve_part1
  |> should.equal(6440)

  get_input(7)
  |> solve_part1
  |> should.equal(249_483_956)
}

pub fn part2_test() {
  example
  |> solve_part2
  |> should.equal(5905)

  get_input(7)
  |> solve_part2
  |> should.equal(252_137_472)
}
