import aoc23.{get_input}
import day13.{solve_part1, solve_part2}
import gleeunit/should

const example = "
#.##..##.
..#.##.#.
##......#
##......#
..#.##.#.
..##..##.
#.#.##.#.

#...##..#
#....#..#
..##..###
#####.##.
#####.##.
..##..###
#....#..#"

pub fn part1_test() {
  example
  |> solve_part1
  |> should.equal(405)

  get_input(13)
  |> solve_part1
  |> should.equal(41_859)
}

pub fn part2_test() {
  example
  |> solve_part2
  |> should.equal(400)

  get_input(13)
  |> solve_part2
  |> should.equal(30_842)
}

pub fn main() {
  part1_test()
  part2_test()
}
