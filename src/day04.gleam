import gleam/dict.{type Dict}
import gleam/float
import gleam/function.{curry3, identity}
import gleam/int
import gleam/list
import gleam/result
import gleam/set.{type Set}
import nibble.{type Parser, drop, keep, many, whitespace}

type CardId =
  Int

type Card {
  Card(id: CardId, winning_numbers: List(Int), numbers_you_have: List(Int))
}

fn card_id_parser() -> Parser(CardId, ctx) {
  nibble.succeed(identity)
  |> drop(nibble.string("Card"))
  |> drop(whitespace())
  |> keep(nibble.int())
}

fn numbers_parser() -> Parser(List(Int), ctx) {
  nibble.succeed(identity)
  |> drop(whitespace())
  |> keep(many(nibble.int(), whitespace()))
  |> drop(whitespace())
}

fn card_parser() -> Parser(Card, ctx) {
  nibble.succeed(curry3(Card))
  |> keep(card_id_parser())
  |> drop(nibble.string(":"))
  |> keep(numbers_parser())
  |> drop(nibble.string("|"))
  |> keep(numbers_parser())
}

fn parse_cards(input: String) -> List(Card) {
  let assert Ok(cards) =
    many(card_parser(), whitespace())
    |> nibble.run(input, _)
  cards
}

fn matching_numbers(card: Card) -> Int {
  card.numbers_you_have
  |> list.filter(list.contains(card.winning_numbers, _))
  |> list.length
}

fn score(card: Card) -> Int {
  let matching = matching_numbers(card)
  let assert Ok(score) = int.power(2, int.to_float(matching - 1))
  float.truncate(score)
}

pub fn solve_part1(input: String) -> Int {
  input
  |> parse_cards
  |> list.map(score)
  |> int.sum
}

fn card_prizes(card: Card, all_card_ids: Set(CardId)) -> List(CardId) {
  case matching_numbers(card) {
    0 -> []
    n -> list.range(card.id + 1, card.id + n)
  }
  |> list.filter(set.contains(all_card_ids, _))
}

fn all_card_prizes(all_cards: List(Card)) -> Dict(CardId, List(CardId)) {
  let all_card_ids =
    all_cards
    |> list.map(fn(card) { card.id })
    |> set.from_list

  all_cards
  |> list.map(fn(card) { #(card.id, card_prizes(card, all_card_ids)) })
  |> dict.from_list
}

fn total_copies_won(
  from card_id: CardId,
  with prizes_table: Dict(CardId, List(CardId)),
) -> Int {
  let copies_won_directly = result.unwrap(dict.get(prizes_table, card_id), [])
  total_cards_with_copies(from: copies_won_directly, with: prizes_table)
}

fn total_cards_with_copies(
  from card_ids: List(CardId),
  with prizes_table: Dict(CardId, List(CardId)),
) -> Int {
  list.length(card_ids) + {
    card_ids
    |> list.map(fn(card_id) {
      total_copies_won(from: card_id, with: prizes_table)
    })
    |> int.sum
  }
}

pub fn solve_part2(input: String) -> Int {
  let cards = parse_cards(input)
  let prizes_table = all_card_prizes(cards)

  cards
  |> list.map(fn(card) { card.id })
  |> total_cards_with_copies(with: prizes_table)
}
