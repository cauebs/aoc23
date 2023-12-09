import gleam/function.{identity}
import gleam/int
import gleam/list
import gleam/option.{type Option, Some}
import gleam/order.{type Order}
import gleam/pair
import gleam/string

type Hand {
  Hand(cards: List(String), bid: Int)
}

fn parse_hand(line: String) -> Hand {
  let assert Ok(#(raw_cards, raw_bid)) = string.split_once(line, " ")
  let cards = string.to_graphemes(raw_cards)
  let assert Ok(bid) = int.parse(raw_bid)
  Hand(cards, bid)
}

fn parse_hands(input: String) -> List(Hand) {
  input
  |> string.trim
  |> string.split("\n")
  |> list.map(parse_hand)
}

fn hand_type_strength(hand: Hand) -> Int {
  let groups =
    hand.cards
    |> list.sort(string.compare)
    |> list.chunk(identity)
    |> list.map(list.length)
    |> list.sort(int.compare)
    |> list.reverse

  case groups {
    [5] -> 6
    [4, 1] -> 5
    [3, 2] -> 4
    [3, 1, 1] -> 3
    [2, 2, 1] -> 2
    [2, 1, 1, 1] -> 1
    _ -> 0
  }
}

fn index_of(needle: a, in haystack: List(a)) -> Option(Int) {
  haystack
  |> list.index_map(fn(i, x) { #(i, x) })
  |> list.find(fn(indexed) { pair.second(indexed) == needle })
  |> option.from_result
  |> option.map(pair.first)
}

const card_order_without_joker = [
  "A", "K", "Q", "J", "T", "9", "8", "7", "6", "5", "4", "3", "2",
]

fn card_strength(card: String, card_order: List(String)) -> Int {
  let assert Some(index) = index_of(card, card_order)
  list.length(card_order) - index
}

fn compare_cards(
  cards1: List(String),
  cards2: List(String),
  card_order: List(String),
) -> Order {
  case cards1, cards2 {
    [], [] -> order.Eq
    [c1, ..rest1], [c2, ..rest2] -> {
      case
        int.compare(
          card_strength(c1, card_order),
          card_strength(c2, card_order),
        )
      {
        order.Eq -> compare_cards(rest1, rest2, card_order)
        o -> o
      }
    }
  }
}

fn compare_hands_without_joker(hand1: Hand, hand2: Hand) -> Order {
  case int.compare(hand_type_strength(hand1), hand_type_strength(hand2)) {
    order.Eq ->
      compare_cards(hand1.cards, hand2.cards, card_order_without_joker)
    o -> o
  }
}

pub fn solve_part1(input: String) -> Int {
  input
  |> parse_hands
  |> list.sort(compare_hands_without_joker)
  |> list.index_map(fn(i, hand) { hand.bid * { i + 1 } })
  |> int.sum
}

fn hand_type_strength_with_joker(hand: Hand) -> Int {
  let #(jokers, other_cards) =
    hand.cards
    |> list.partition(fn(card) { card == "J" })

  let groups =
    other_cards
    |> list.sort(string.compare)
    |> list.chunk(identity)
    |> list.map(list.length)
    |> list.sort(int.compare)
    |> list.reverse

  let groups_with_jokers = case groups {
    [] -> [5]
    [largest, ..others] -> [largest + list.length(jokers), ..others]
  }

  case groups_with_jokers {
    [5] -> 6
    [4, 1] -> 5
    [3, 2] -> 4
    [3, 1, 1] -> 3
    [2, 2, 1] -> 2
    [2, 1, 1, 1] -> 1
    _ -> 0
  }
}

const card_order_with_joker = [
  "A", "K", "Q", "T", "9", "8", "7", "6", "5", "4", "3", "2", "J",
]

fn compare_hands_with_joker(hand1: Hand, hand2: Hand) -> Order {
  case
    int.compare(
      hand_type_strength_with_joker(hand1),
      hand_type_strength_with_joker(hand2),
    )
  {
    order.Eq -> compare_cards(hand1.cards, hand2.cards, card_order_with_joker)
    o -> o
  }
}

pub fn solve_part2(input: String) -> Int {
  input
  |> parse_hands
  |> list.sort(compare_hands_with_joker)
  |> list.index_map(fn(i, hand) { hand.bid * { i + 1 } })
  |> int.sum
}
