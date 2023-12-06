import gleam/function.{curry2, curry3, identity}
import gleam/int
import gleam/io
import gleam/list
import gleam/option.{type Option, None, Some}
import gleam/order.{type Order}
import nibble.{type Parser, drop, keep, many, spaces, whitespace}
import nibble/predicates

type Almanac {
  Almanac(seeds: List(Int), maps: List(Map))
}

type Map =
  List(MapEntry)

type MapEntry {
  MapEntry(
    destination_range_start: Int,
    source_range_start: Int,
    range_length: Int,
  )
}

fn seeds_parser() -> Parser(List(Int), ctx) {
  nibble.succeed(identity)
  |> drop(nibble.string("seeds: "))
  |> keep(many(nibble.int(), spaces()))
}

fn map_entry_parser() -> Parser(MapEntry, ctx) {
  nibble.succeed(curry3(MapEntry))
  |> keep(nibble.int())
  |> drop(whitespace())
  |> keep(nibble.int())
  |> drop(whitespace())
  |> keep(nibble.int())
}

fn sort_entries(map: Map) -> Map {
  list.sort(
    map,
    by: fn(a: MapEntry, b: MapEntry) {
      int.compare(a.source_range_start, b.source_range_start)
    },
  )
}

fn map_parser() -> Parser(Map, ctx) {
  nibble.succeed(identity)
  |> drop(nibble.take_until(predicates.is_whitespace))
  |> drop(spaces())
  |> drop(nibble.string("map:"))
  |> drop(whitespace())
  |> keep(many(map_entry_parser(), whitespace()))
  |> nibble.map(sort_entries)
}

fn almanac_parser() -> Parser(Almanac, ctx) {
  nibble.succeed(curry2(Almanac))
  |> keep(seeds_parser())
  |> drop(whitespace())
  |> keep(many(map_parser(), whitespace()))
}

fn parse_almanac(input: String) -> Almanac {
  let assert Ok(almanac) = nibble.run(input, almanac_parser())
  almanac
}

fn compare_id_to_source_range(id: Int, entry: MapEntry) -> Order {
  let start = entry.source_range_start
  let end = start + entry.range_length
  case id {
    _ if id < start -> order.Lt
    _ if id >= end -> order.Gt
    _ -> order.Eq
  }
}

fn binary_search(l: List(a), with predicate: fn(a) -> Order) -> Option(a) {
  case l {
    [] -> None
    [single] ->
      case predicate(single) {
        order.Eq -> Some(single)
        _ -> None
      }
    l -> {
      let half = list.length(l) / 2
      let assert Ok(middle) = list.at(l, half)
      case predicate(middle) {
        order.Lt -> binary_search(list.take(l, half), predicate)
        order.Eq -> Some(middle)
        order.Gt -> binary_search(list.drop(l, half), predicate)
      }
    }
  }
}

fn look_up(id: Int, map: Map) -> Int {
  map
  |> binary_search(with: compare_id_to_source_range(id, _))
  |> option.map(fn(entry) {
    entry.destination_range_start + { id - entry.source_range_start }
  })
  |> option.unwrap(id)
}

fn seed_location(seed: Int, almanac: Almanac) -> Int {
  list.fold(from: seed, over: almanac.maps, with: look_up)
}

fn closest_seed_location(seeds: List(Int), almanac: Almanac) -> Int {
  let assert Ok(location) =
    seeds
    |> list.map(seed_location(_, almanac))
    |> list.reduce(int.min)

  location
}

pub fn solve_part1(input: String) -> Int {
  let almanac = parse_almanac(input)

  almanac.seeds
  |> closest_seed_location(almanac)
}

fn seeds_from_ranges(ranges_description: List(Int)) -> List(Int) {
  ranges_description
  |> list.sized_chunk(2)
  |> list.flat_map(fn(range) {
    case range {
      [start, size] -> list.range(start, start + size - 1)
      _ -> []
    }
  })
}

pub fn solve_part2(input: String) -> Int {
  let almanac = parse_almanac(input)

  almanac.seeds
  |> seeds_from_ranges
  |> closest_seed_location(almanac)
}
