import aoc/internal.{type Coord}
import gleam/dict
import gleam/int
import gleam/io
import gleam/iterator
import gleam/list
import gleam/regex
import gleam/set.{type Set}
import gleam/string

const row = 2_000_000

// 4000000
// const search_area = 20

// PERF: Currently runs in ~15s. If I use a custom range type instead of sets, I
// may be able to increase performance. Using a custom range type also means
// implementing a merge function for it
pub fn part_1(input: String) -> Int {
  let sensors =
    input
    |> internal.lines()
    |> list.filter(fn(line) { !string.is_empty(line) })
    |> list.map(parse_line)
    |> dict.from_list()
  let beacons = sensors |> dict.values() |> set.from_list()

  sensors
  |> dict.map_values(fn(sensor, beacon) { x_range(sensor, beacon, row) })
  |> dict.fold(from: set.new(), with: fn(acc, _, range) {
    set.union(acc, range)
  })
  |> set.difference(minus: beacons)
  |> set.size()
}

pub fn part_2(input: String) -> Int {
  // let range = iterator.range(from: 0, to: 4_000_000)
  // range
  // |> iterator.map(fn(x) { range |> iterator.map(fn(y) { #(x, y) }) })
  // |> iterator.flatten()
  // |> iterator.map(io.debug)
  // |> iterator.to_list()
  // |> io.debug()

  let sensors =
    input
    |> internal.lines()
    |> list.filter(fn(line) { !string.is_empty(line) })
    |> list.map(parse_line)
    |> dict.from_list()
  let beacons = sensors |> dict.values() |> set.from_list()

  {
    use y <- iterator.map(iterator.range(from: 0, to: 4_000_000))
    sensors
    |> dict.map_values(fn(sensor, beacon) { x_range(sensor, beacon, y) })
    |> dict.fold(from: set.new(), with: fn(acc, _, range) {
      set.union(acc, range)
    })
    |> set.difference(minus: beacons)
    |> io.debug()
  }
  |> iterator.run()

  todo
}

/// Returns the coordinates for a sensor and its closest beacon.
fn parse_line(line: String) -> #(Coord, Coord) {
  let assert Ok(re) = regex.from_string("-?\\d+")
  let assert [sx, sy, bx, by] =
    regex.scan(line, with: re)
    |> list.map(fn(m) { m.content })
    |> list.filter_map(int.parse)

  #(#(sx, sy), #(bx, by))
}

@internal
pub fn manhattan_distance(from from: Coord, to to: Coord) -> Int {
  let #(x1, y1) = from
  let #(x2, y2) = to

  let x = int.absolute_value(x1 - x2)
  let y = int.absolute_value(y1 - y2)

  x + y
}

/// Returns a set of coordinates that are in range of the given sensor along the
/// given y-value.
fn x_range(sensor: Coord, beacon: Coord, over y: Int) -> Set(Coord) {
  let distance = manhattan_distance(from: sensor, to: beacon)
  let y_distance_to_target_row = int.absolute_value(sensor.1 - y)
  let x_distance_leftover =
    int.absolute_value(distance - y_distance_to_target_row)

  case y_distance_to_target_row <= distance {
    True ->
      list.range(
        from: sensor.0 - x_distance_leftover,
        to: sensor.0 + x_distance_leftover,
      )
      |> list.map(fn(x) { #(x, y) })
      |> set.from_list()
    False -> set.new()
  }
}
