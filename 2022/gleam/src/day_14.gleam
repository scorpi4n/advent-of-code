import aoc/internal.{type Coord}
import gleam/bool
import gleam/dict.{type Dict}
import gleam/int
import gleam/io
import gleam/iterator
import gleam/list.{Continue, Stop}
import gleam/option.{None, Some}
import gleam/pair
import gleam/result
import gleam/string

type State {
  Sand
  Rock
}

const sand_origin = #(500, 0)

pub fn part_1(input: String) -> Int {
  let assert Ok(cave) =
    input
    |> internal.lines()
    |> list.filter(fn(line) { !string.is_empty(line) })
    |> list.map(parse)
    |> list.reduce(dict.merge)

  iterator.iterate(cave, fall1(from: sand_origin, in: _))
  // drop original cave, that is the first comparison and will always stop
  // folding
  |> iterator.drop(1)
  |> iterator.fold_until(from: cave, with: fn(acc, curr) {
    case acc == curr {
      True -> Stop(acc)
      False -> Continue(curr)
    }
  })
  |> dict.filter(fn(_, v) { v == Sand })
  |> dict.size()
}

// OPTIM: Instead of properly simulating each grain of sand, I could calculate
// the area the sand would take up, subtracting all coords that are covered by
// rock. The current implementation takes forever to run
pub fn part_2(input: String) -> Int {
  let assert Ok(cave) =
    input
    |> internal.lines()
    |> list.filter(fn(line) { !string.is_empty(line) })
    |> list.map(parse)
    |> list.reduce(dict.merge)

  iterator.iterate(cave, fall2(from: sand_origin, in: _))
  // drop original cave, that is the first comparison and will always stop
  // folding
  |> iterator.drop(1)
  |> iterator.fold_until(from: cave, with: fn(acc, curr) {
    case acc == curr {
      True -> Stop(acc)
      False -> Continue(curr)
    }
  })
  |> dict.filter(fn(_, v) { v == Sand })
  |> dict.size()
}

fn parse(string: String) -> Dict(Coord, State) {
  string.split(string, on: "->")
  |> list.map(fn(unparsed_coord) {
    let assert Ok(#(unparsed_x, unparsed_y)) =
      unparsed_coord |> string.trim() |> string.split_once(on: ",")

    let assert Ok(x) = int.parse(unparsed_x)
    let assert Ok(y) = int.parse(unparsed_y)
    #(x, y)
  })
  |> list.window_by_2()
  |> list.flat_map(fn(pair) {
    let #(from, to) = pair

    use x <- list.flat_map(list.range(from: from.0, to: to.0))
    use y <- list.map(list.range(from: from.1, to: to.1))
    #(x, y)
  })
  |> list.map(fn(coord) { #(coord, Rock) })
  |> dict.from_list()
}

fn fall1(from coord: Coord, in cave: Dict(Coord, State)) -> Dict(Coord, State) {
  let #(x, y) = coord
  let assert Ok(abyss_threshold) =
    cave |> dict.keys() |> list.map(pair.second) |> list.reduce(int.max)

  use <- bool.guard(return: cave, when: y >= abyss_threshold)

  let falling_to = {
    let down = #(x, y + 1)
    let down_left = #(x - 1, y + 1)
    let down_right = #(x + 1, y + 1)

    use <- bool.guard(Some(down), when: !dict.has_key(cave, down))
    use <- bool.guard(Some(down_left), when: !dict.has_key(cave, down_left))
    use <- bool.guard(Some(down_right), when: !dict.has_key(cave, down_right))
    None
  }

  case falling_to {
    None -> dict.insert(Sand, into: cave, for: coord)
    Some(to) -> fall1(to, in: cave)
  }
}

fn fall2(from coord: Coord, in cave: Dict(Coord, State)) -> Dict(Coord, State) {
  let #(x, y) = coord
  let assert Ok(floor) =
    cave
    |> dict.filter(fn(_, v) { v == Rock })
    |> dict.keys()
    |> list.map(pair.second)
    |> list.reduce(int.max)
    |> result.map(int.add(_, 2))

  let falling_to = {
    let down = #(x, y + 1)
    let down_left = #(x - 1, y + 1)
    let down_right = #(x + 1, y + 1)

    use <- bool.guard(None, when: y + 1 >= floor)
    use <- bool.guard(Some(down), when: !dict.has_key(cave, down))
    use <- bool.guard(Some(down_left), when: !dict.has_key(cave, down_left))
    use <- bool.guard(Some(down_right), when: !dict.has_key(cave, down_right))
    None
  }

  case falling_to {
    None -> dict.insert(Sand, into: cave, for: coord)
    Some(to) -> fall2(to, in: cave)
  }
}
