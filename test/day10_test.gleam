import aoc23.{get_input}
import day10.{solve_part1, solve_part2}
import gleeunit/should

const example1 = "
-L|F7
7S-7|
L|7||
-L-J|
L|-JF"

const example2 = "
..F7.
.FJ|.
SJ.L7
|F--J
LJ..."

const example3 = "
...........
.S-------7.
.|F-----7|.
.||.....||.
.||.....||.
.|L-7.F-J|.
.|..|.|..|.
.L--J.L--J.
..........."

const example4 = "
.F----7F7F7F7F-7....
.|F--7||||||||FJ....
.||.FJ||||||||L7....
FJL7L7LJLJ||LJ.L-7..
L--J.L7...LJS7F-7L7.
....F-J..F7FJ|L7L7L7
....L7.F7||L7|.L7L7|
.....|FJLJ|FJ|F7|.LJ
....FJL-7.||.||||...
....L---J.LJ.LJLJ..."

const example5 = "
FF7FSF7F7F7F7F7F---7
L|LJ||||||||||||F--J
FL-7LJLJ||||||LJL-77
F--JF--7||LJLJ7F7FJ-
L---JF-JLJ.||-FJLJJ7
|F|F-JF---7F7-L7L|7|
|FFJF7L7F-JF7|JL---7
7-L-JL7||F7|L7F-7F7|
L.L7LFJ|||||FJL7||LJ
L7JLJL-JLJLJL--JLJ.L"

pub fn part1_test() {
  example1
  |> solve_part1
  |> should.equal(4)

  example2
  |> solve_part1
  |> should.equal(8)

  get_input(10)
  |> solve_part1
  |> should.equal(6725)
}

pub fn part2_test() {
  example3
  |> solve_part2
  |> should.equal(4)

  example4
  |> solve_part2
  |> should.equal(8)

  example5
  |> solve_part2
  |> should.equal(10)

  get_input(10)
  |> solve_part2
  |> should.equal(383)
}
