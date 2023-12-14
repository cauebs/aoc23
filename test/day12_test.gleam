import aoc23.{get_input}
import day12.{solve_part1, solve_part2}
import gleeunit/should

const example = "
???.### 1,1,3
.??..??...?##. 1,1,3
?#?#?#?#?#?#?#? 1,3,1,6
????.#...#... 4,1,1
????.######..#####. 1,6,5
?###???????? 3,2,1"

pub fn part1_test() {
  "?.????##??.?#???. 2,3"
  |> solve_part1
  |> should.equal(2)

  example
  |> solve_part1
  |> should.equal(21)

  get_input(12)
  |> solve_part1
  |> should.equal(7633)
}

pub fn part2_test() {
  todo
  // example
  // |> solve_part2
  // |> should.equal(525_152)

  // get_input(12)
  // |> solve_part2
  // |> should.equal(0)
}

pub fn main() {
  part1_test()
  part2_test()
}
