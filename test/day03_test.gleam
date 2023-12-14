import aoc23.{get_input}
import day03.{solve_part1, solve_part2}
import gleeunit/should

const example = "467..114..
...*......
..35..633.
......#...
617*......
.....+.58.
..592.....
......755.
...$.*....
.664.598.."

pub fn part1_test() {
  example
  |> solve_part1
  |> should.equal(4361)

  get_input(3)
  |> solve_part1
  |> should.equal(553_825)
}

pub fn part2_test() {
  example
  |> solve_part2
  |> should.equal(467_835)

  get_input(3)
  |> solve_part2
  |> should.equal(93_994_191)
}

pub fn main() {
  part1_test()
  part2_test()
}
