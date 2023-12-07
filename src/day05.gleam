import gleam/function.{curry2, curry3, identity}
import gleam/int
import gleam/iterator.{type Iterator}
import gleam/list
import gleam/option.{type Option, None, Some}
import gleam/order.{type Order}
import gleam/otp/task
import gleam/result
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

fn par_map(over l: List(a), with func: fn(a) -> b) -> List(b) {
  let run_in_parallel = fn(x) { task.async(fn() { func(x) }) }
  l
  |> list.map(run_in_parallel)
  |> list.map(task.await_forever)
}

fn closest_seed_location(seeds: Iterator(Int), almanac: Almanac) -> Int {
  let assert Ok(location) =
    seeds
    |> iterator.sized_chunk(1_000_000)
    |> iterator.to_list
    |> par_map(fn(chunk) {
      chunk
      |> list.map(location_for_seed(_, almanac))
      |> iterator.from_list
    })
    |> iterator.from_list
    |> iterator.flatten
    |> iterator.reduce(int.min)

  location
}

pub fn solve_part1(input: String) -> Int {
  let almanac = parse_almanac(input)

  almanac.seeds_description
  |> iterator.from_list
  |> closest_seed_location(almanac)
}

type Range {
  Range(start: Int, length: Int)
}

fn join_ranges(range1: Range, range2: Range) -> List(Range) {
  let l_end = range1.start + range1.length
  let overlap = l_end - range2.start

  case overlap > 0 {
    True -> [
      Range(
        start: range1.start,
        length: range1.length - overlap + range2.length,
      ),
    ]
    False -> [range1, range2]
  }
}

fn remove_overlaps(ranges: List(Range)) -> List(Range) {
  ranges
  |> list.sort(fn(a, b) { int.compare(a.start, b.start) })
  |> list.map(fn(range) { [range] })
  |> list.reduce(with: fn(ranges, next) {
    let assert Ok(last) = list.last(ranges)
    let assert [next] = next
    join_ranges(last, next)
  })
  |> result.unwrap([])
}

pub fn solve_part2(input: String) -> Int {
  let almanac = parse_almanac(input)

  almanac.seeds_description
  |> list.sized_chunk(2)
  |> list.map(fn(range) {
    let assert [start, length] = range
    Range(start, length)
  })
  |> remove_overlaps
  |> iterator.from_list
  |> iterator.flat_map(fn(range) {
    iterator.range(range.start, range.start + range.length - 1)
  })
  |> closest_seed_location(almanac)
}
