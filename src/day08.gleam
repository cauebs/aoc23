import gleam/dict.{type Dict}
import gleam/function.{curry2, curry3}
import gleam/int
import gleam/iterator as it
import gleam/list
import gleam/pair
import gleam/order
import gleam/string
import nibble.{type Parser, drop, keep, many, one_of, whitespace}
import nibble/predicates

type Direction {
  Left
  Right
}

type Node =
  String

type Map {
  Map(instructions: List(Direction), nodes: Dict(Node, #(Node, Node)))
}

fn node_parser() -> Parser(#(Node, #(Node, Node)), ctx) {
  nibble.succeed(curry3(fn(source, dest_left, dest_right) {
    #(source, #(dest_left, dest_right))
  }))
  |> keep(nibble.take_while(predicates.is_alphanum))
  |> drop(nibble.string(" = ("))
  |> keep(nibble.take_while(predicates.is_alphanum))
  |> drop(nibble.string(", "))
  |> keep(nibble.take_while(predicates.is_alphanum))
  |> drop(nibble.string(")"))
}

fn direction_parser() -> Parser(Direction, ctx) {
  one_of([
    nibble.grapheme("L")
    |> nibble.map(fn(_) { Left }),
    nibble.grapheme("R")
    |> nibble.map(fn(_) { Right }),
  ])
}

fn map_parser() -> Parser(Map, ctx) {
  nibble.succeed(curry2(Map))
  |> keep(many(direction_parser(), nibble.spaces()))
  |> drop(whitespace())
  |> keep(
    many(node_parser(), whitespace())
    |> nibble.map(dict.from_list),
  )
}

fn parse_map(input: String) -> Map {
  let assert Ok(map) = nibble.run(input, map_parser())
  map
}

fn move(current_node: Node, direction: Direction, map: Map) -> Node {
  let assert Ok(#(left, right)) = dict.get(map.nodes, current_node)

  case direction {
    Left -> left
    Right -> right
  }
}

fn steps_to_reach(from start: Node, to end: Node, with map: Map) -> Int {
  map.instructions
  |> it.from_list
  |> it.cycle
  |> it.scan(
    from: start,
    with: fn(node, direction) { move(node, direction, map) },
  )
  |> it.take_while(fn(node) { node != end })
  |> it.length
  |> int.add(1)
}

pub fn solve_part1(input: String) -> Int {
  input
  |> parse_map
  |> steps_to_reach(from: "AAA", to: "ZZZ", with: _)
}

fn steps_from_node_to_each_z(starting_node: Node, map: Map) -> List(Int) {
  let from_first_z =
    map.instructions
    |> it.from_list
    |> it.cycle
    |> it.scan(
      from: #(0, starting_node),
      with: fn(steps_and_node, direction) {
        let #(steps, node) = steps_and_node
        #(steps + 1, move(node, direction, map))
      },
    )
    |> it.drop_while(fn(i_node) { !string.ends_with(i_node.1, "Z") })

  let assert Ok(#(steps_to_first_z, first_z)) = it.first(from_first_z)

  from_first_z
  |> it.drop(1)
  |> it.filter(fn(i_node) { string.ends_with(i_node.1, "Z") })
  |> it.take_while(fn(i_node) { i_node.1 != first_z })
  |> it.map(pair.first)
  |> it.to_list
  |> list.prepend(steps_to_first_z)
}

fn gcd(a: Int, b: Int) -> Int {
  case int.compare(a, b) {
    order.Lt -> gcd(b, a)
    order.Eq -> a
    order.Gt -> gcd(a - b, b)
  }
}

fn lcm(a: Int, b: Int) -> Int {
  a * b / gcd(a, b)
}

pub fn solve_part2(input: String) -> Int {
  let map = parse_map(input)

  let assert Ok(result) =
    map.nodes
    |> dict.keys
    |> list.filter(string.ends_with(_, "A"))
    |> list.map(fn(node) {
      let assert Ok(steps) =
        steps_from_node_to_each_z(node, map)
        |> list.first
      steps
    })
    |> list.reduce(lcm)

  result
}
