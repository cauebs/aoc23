import aoc23.{get_input}
import day01.{solve_part1, solve_part2}
import gleeunit/should

pub fn part1_test() {
  "1abc2
pqr3stu8vwx
a1b2c3d4e5f
treb7uchet"
  |> solve_part1
  |> should.equal(142)

  get_input(1)
  |> solve_part1
  |> should.equal(55_712)
}

pub fn part2_test() {
  "two1nine
eightwothree
abcone2threexyz
xtwone3four
4nineeightseven2
zoneight234
7pqrstsixteen"
  |> solve_part2
  |> should.equal(281)

  get_input(1)
  |> solve_part2
  |> should.equal(55_413)
}
