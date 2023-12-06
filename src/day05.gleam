import gleam/function.{curry2, curry3, identity}
import gleam/int
import gleam/io
import gleam/list
import gleam/iterator.{type Iterator}
import gleam/option.{type Option, None, Some}
import gleam/order.{type Order}
import nibble.{type Parser, drop, keep, many, spaces, whitespace}
import nibble/predicates

type Almanac {
  Almanac(seeds_description: List(Int), maps: List(Map))
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

fn sort_entries_by_source(map: Map) -> Map {
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
  |> nibble.map(sort_entries_by_source)
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

fn compare_to_range(x: Int, start: Int, length: Int) -> Order {
  let end = start + length
  case x {
    _ if x < start -> order.Lt
    _ if x >= end -> order.Gt
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

fn lookup(id: Int, map: Map) -> Int {
  map
  |> binary_search(fn(entry) {
    compare_to_range(id, entry.source_range_start, entry.range_length)
  })
  |> option.map(fn(entry) {
    entry.destination_range_start + { id - entry.source_range_start }
  })
  |> option.unwrap(id)
}

fn location_for_seed(seed: Int, almanac: Almanac) -> Int {
  list.fold(from: seed, over: almanac.maps, with: lookup)
}

fn closest_seed_location(seeds: List(Int), almanac: Almanac) -> Int {
  let assert Ok(location) =
    seeds
    |> list.map(location_for_seed(_, almanac))
    |> list.reduce(int.min)

  location
}

pub fn solve_part1(input: String) -> Int {
  let almanac = parse_almanac(input)

  almanac.seeds_description
  |> closest_seed_location(almanac)
}

fn sort_entries_by_destination(map: Map) -> Map {
  list.sort(
    map,
    by: fn(a: MapEntry, b: MapEntry) {
      int.compare(a.destination_range_start, b.destination_range_start)
    },
  )
}

fn destination_range(entry: MapEntry) -> Iterator(Int) {
  let first = entry.destination_range_start
  let last = first + entry.range_length - 1
  iterator.range(first, last)
}

fn seed_in_ranges(seed: Int, ranges_description: List(Int)) -> Bool {
  ranges_description
  |> list.sized_chunk(2)
  |> list.any(fn(range) {
    let assert [start, size] = range
    start <= seed && seed < start + size
  })
}

fn reverse_lookup(id: Int, map_sorted_by_destination: Map) -> Int {
  map_sorted_by_destination
  |> binary_search(fn(entry) {
    compare_to_range(id, entry.destination_range_start, entry.range_length)
  })
  |> option.map(fn(entry) {
    entry.source_range_start + { id - entry.destination_range_start }
  })
  |> option.unwrap(id)
}

fn seed_for_location(location: Int, almanac: Almanac) -> Int {
  list.fold_right(from: location, over: almanac.maps, with: reverse_lookup)
}

pub fn solve_part2(input: String) -> Int {
  let almanac = parse_almanac(input)
  let almanac =
    Almanac(
      seeds_description: almanac.seeds_description
      |> list.sort(by: int.compare),
      maps: almanac.maps
      |> list.map(sort_entries_by_destination),
    )

  let assert Ok(location_map) = list.last(almanac.maps)

  let assert Ok(closest_seed_location) =
    location_map
    |> iterator.from_list
    |> iterator.flat_map(destination_range)
    |> iterator.map(seed_for_location(_, almanac))
    |> iterator.find(seed_in_ranges(_, almanac.seeds_description))

  closest_seed_location
}
