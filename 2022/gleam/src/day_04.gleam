import aoc/internal
import gleam/int
import gleam/list
import gleam/set.{type Set}
import gleam/string

pub fn part_1(input: String) -> Int {
  input
  |> internal.lines()
  |> list.filter(fn(line) { !string.is_empty(line) })
  |> list.filter(fn(line) {
    let #(larger, smaller) = {
      let assert Ok(#(unparsed_range_a, unparsed_range_b)) =
        string.split_once(line, on: ",")

      let range_a =
        unparsed_range_a
        |> parse_range()
        |> set.from_list()
      let range_b =
        unparsed_range_b
        |> parse_range()
        |> set.from_list()

      case set.size(range_a) > set.size(range_b) {
        True -> #(range_a, range_b)
        False -> #(range_b, range_a)
      }
    }

    is_superset(larger, smaller)
  })
  |> list.length()
}

pub fn part_2(input: String) -> Int {
  input
  |> internal.lines()
  |> list.filter(fn(line) { !string.is_empty(line) })
  |> list.filter(fn(line) {
    let assert Ok(#(unparsed_range_a, unparsed_range_b)) =
      string.split_once(line, on: ",")

    let range_a =
      unparsed_range_a
      |> parse_range()
      |> set.from_list()
    let range_b =
      unparsed_range_b
      |> parse_range()
      |> set.from_list()

    let intersection = set.intersection(of: range_a, and: range_b)
    set.size(intersection) > 0
  })
  |> list.length()
}

fn parse_range(s: String) -> List(Int) {
  let assert Ok(#(start, end)) = string.split_once(s, on: "-")
  let assert Ok(start) = int.parse(start)
  let assert Ok(end) = int.parse(end)

  list.range(from: start, to: end)
}

fn is_superset(a: Set(t), of b: Set(t)) -> Bool {
  set.filter(in: b, keeping: fn(member) { !set.contains(in: a, this: member) })
  |> set.size()
  == 0
}
