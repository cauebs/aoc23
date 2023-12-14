import aoc23.{get_input}
import day11.{solve}
import gleeunit/should

const example = "
...#......
.......#..
#.........
..........
......#...
.#........
.........#
..........
.......#..
#...#....."

pub fn part1_test() {
  example
  |> solve(2)
  |> should.equal(374)

  get_input(11)
  |> solve(2)
  |> should.equal(9_312_968)
}

pub fn part2_test() {
  example
  |> solve(10)
  |> should.equal(1030)

  example
  |> solve(100)
  |> should.equal(8410)

  get_input(11)
  |> solve(1_000_000)
  |> should.equal(597_714_117_556)
}

pub fn main() {
  part1_test()
  part2_test()
}
