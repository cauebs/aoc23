import gleam/dict.{type Dict}
import gleam/function
import gleam/int
import gleam/list
import gleam/option.{Some}
import gleam/pair
import gleam/result
import gleam/string
import nibble.{type Parser, drop, keep, many}
import nibble/predicates

type Color =
  String

type Cubes =
  Dict(Color, Int)

pub type Limits =
  Dict(Color, Int)

type Game {
  Game(id: Int, rounds: List(Cubes))
}

fn game_id_parser() -> Parser(Int, ctx) {
  nibble.succeed(function.identity)
  |> drop(nibble.string("Game"))
  |> drop(nibble.whitespace())
  |> keep(nibble.int())
}

fn cubes_parser() -> Parser(#(Color, Int), ctx) {
  nibble.succeed(function.curry2(function.flip(pair.new)))
  |> keep(nibble.int())
  |> drop(nibble.whitespace())
  |> keep(nibble.take_while(predicates.is_alphanum))
}

fn round_parser() -> Parser(Cubes, ctx) {
  nibble.succeed(dict.from_list)
  |> keep(many(cubes_parser(), nibble.string(", ")))
}

fn rounds_parser() -> Parser(List(Cubes), ctx) {
  nibble.succeed(function.identity)
  |> keep(many(round_parser(), nibble.string("; ")))
}

fn game_parser() -> Parser(Game, ctx) {
  nibble.succeed(function.curry2(Game))
  |> keep(game_id_parser())
  |> drop(nibble.string(": "))
  |> keep(rounds_parser())
}

fn parse_game(line: String) -> Game {
  let assert Ok(game) = nibble.run(line, game_parser())
  game
}

fn parse_games(input: String) -> List(Game) {
  input
  |> string.trim_right
  |> string.split("\n")
  |> list.map(parse_game)
}

fn is_round_possible(round: Cubes, limits: Limits) -> Bool {
  limits
  |> dict.to_list
  |> list.all(fn(limit) {
    let #(color, amount_available) = limit
    let amount_in_round =
      dict.get(round, color)
      |> result.unwrap(or: 0)
    amount_in_round <= amount_available
  })
}

fn is_game_possible(game: Game, limits: Limits) -> Bool {
  game.rounds
  |> list.all(is_round_possible(_, limits))
}

pub fn solve_part1(input: String, limits: Limits) -> Int {
  parse_games(input)
  |> list.filter(is_game_possible(_, limits))
  |> list.map(fn(game) { game.id })
  |> int.sum
}

fn update_if_greater(
  in d: Dict(k, Int),
  update key: k,
  to new_value: Int,
) -> Dict(k, Int) {
  dict.update(
    in: d,
    update: key,
    with: fn(maybe_value) {
      case maybe_value {
        Some(current_value) if current_value >= new_value -> current_value
        _ -> new_value
      }
    },
  )
}

fn upgrade(from d1: Dict(a, Int), to d2: Dict(a, Int)) -> Dict(a, Int) {
  list.fold(
    over: dict.to_list(d2),
    from: d1,
    with: fn(d, entry) {
      let #(k, v) = entry
      update_if_greater(in: d, update: k, to: v)
    },
  )
}

fn minimum_set(game: Game) -> Cubes {
  let assert Ok(min) = list.reduce(game.rounds, with: upgrade)
  min
}

fn power(cubes: Cubes) -> Int {
  cubes
  |> dict.values
  |> int.product
}

pub fn solve_part2(input: String) -> Int {
  parse_games(input)
  |> list.map(minimum_set)
  |> list.map(power)
  |> int.sum
}
