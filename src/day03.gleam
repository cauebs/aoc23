import gleam/bool
import gleam/dict.{type Dict}
import gleam/function
import gleam/int
import gleam/iterator
import gleam/list
import gleam/pair
import gleam/result
import gleam/string
import nibble/predicates.{is_digit}

type Position {
  Position(row: Int, column: Int)
}

type Number {
  Number(row: Int, first_column: Int, last_column: Int, value: Int)
}

fn number_from_indexed_chars(
  row: Int,
  indexed_chars: List(#(Int, String)),
) -> Result(Number, Nil) {
  use #(first_column, _) <- result.try(list.first(indexed_chars))
  use #(last_column, _) <- result.try(list.last(indexed_chars))
  use value <- result.try(
    indexed_chars
    |> list.map(pair.second)
    |> string.join(with: "")
    |> int.parse,
  )

  Ok(Number(row, first_column, last_column, value))
}

type Symbols =
  Dict(Position, String)

fn parse_numbers(
  at row: Int,
  from indexed_chars: List(#(Int, String)),
) -> List(Number) {
  let is_digit = function.compose(pair.second, is_digit)
  let is_not_digit = function.compose(is_digit, bool.negate)

  let #(maybe_digits, rest) =
    indexed_chars
    |> list.drop_while(is_not_digit)
    |> list.split_while(is_digit)

  let other_numbers = case rest {
    [] -> []
    rest -> parse_numbers(row, rest)
  }

  case number_from_indexed_chars(row, maybe_digits) {
    Ok(number) -> [number, ..other_numbers]
    _ -> other_numbers
  }
}

fn parse_symbols(
  at row: Int,
  from indexed_chars: List(#(Int, String)),
) -> Symbols {
  indexed_chars
  |> list.filter_map(fn(indexed_char) {
    let #(column, char) = indexed_char
    let is_symbol = char != "." && !is_digit(char)
    case is_symbol {
      True -> Ok(#(Position(row, column), char))
      False -> Error(Nil)
    }
  })
  |> dict.from_list
}

fn parse_line(at row: Int, from line: String) -> #(List(Number), Symbols) {
  let indexed_chars =
    line
    |> string.to_graphemes
    |> iterator.from_list
    |> iterator.index
    |> iterator.to_list

  #(parse_numbers(row, indexed_chars), parse_symbols(row, indexed_chars))
}

fn parse_input(input: String) -> #(List(Number), Symbols) {
  input
  |> string.split("\n")
  |> list.index_fold(
    from: #([], dict.new()),
    with: fn(numbers_and_symbols, line, row) {
      let #(numbers, symbols) = numbers_and_symbols
      let #(new_numbers, new_symbols) = parse_line(row, line)
      #(
        list.append(numbers, new_numbers),
        dict.merge(into: symbols, from: new_symbols),
      )
    },
  )
}

fn neighbors(number: Number) -> List(Position) {
  let rows = list.range(number.row - 1, number.row + 1)
  let columns = list.range(number.first_column - 1, number.last_column + 1)

  {
    use row <- list.map(rows)
    use column <- list.map(columns)
    Position(row, column)
  }
  |> list.flatten
}

fn is_adjacecent_to_any_symbols(number: Number, symbols: Symbols) -> Bool {
  neighbors(number)
  |> list.any(dict.has_key(symbols, _))
}

pub fn solve_part1(input: String) -> Int {
  let #(numbers, symbols) = parse_input(input)
  numbers
  |> list.filter(is_adjacecent_to_any_symbols(_, symbols))
  |> list.map(fn(number) { number.value })
  |> int.sum
}

fn is_adjacecent_to(number: Number, pos: Position) -> Bool {
  neighbors(number)
  |> list.contains(pos)
}

fn gear_ratio(symbol: Position, numbers: List(Number)) -> Result(Int, Nil) {
  case
    numbers
    |> list.filter(is_adjacecent_to(_, symbol))
  {
    [a, b] -> Ok(a.value * b.value)
    _ -> Error(Nil)
  }
}

fn gear_positions(symbols: Symbols) -> List(Position) {
  symbols
  |> dict.filter(fn(_pos, symbol) { symbol == "*" })
  |> dict.keys
}

pub fn solve_part2(input: String) -> Int {
  let #(numbers, symbols) = parse_input(input)

  symbols
  |> gear_positions
  |> list.filter_map(gear_ratio(_, numbers))
  |> int.sum
}
