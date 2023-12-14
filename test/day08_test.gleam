import aoc23.{get_input}
import day08.{solve_part1, solve_part2}
import gleeunit/should

const example1 = "RL

AAA = (BBB, CCC)
BBB = (DDD, EEE)
CCC = (ZZZ, GGG)
DDD = (DDD, DDD)
EEE = (EEE, EEE)
GGG = (GGG, GGG)
ZZZ = (ZZZ, ZZZ)"

const example2 = "LLR

AAA = (BBB, BBB)
BBB = (AAA, ZZZ)
ZZZ = (ZZZ, ZZZ)"

const example3 = "LR

11A = (11B, XXX)
11B = (XXX, 11Z)
11Z = (11B, XXX)
22A = (22B, XXX)
22B = (22C, 22C)
22C = (22Z, 22Z)
22Z = (22B, 22B)
XXX = (XXX, XXX)"

pub fn part1_test() {
  example1
  |> solve_part1
  |> should.equal(2)

  example2
  |> solve_part1
  |> should.equal(6)

  get_input(8)
  |> solve_part1
  |> should.equal(19_783)
}

pub fn part2_test() {
  example3
  |> solve_part2
  |> should.equal(6)

  get_input(8)
  |> solve_part2
  |> should.equal(9_177_460_370_549)
}

pub fn main() {
  part1_test()
  part2_test()
}
