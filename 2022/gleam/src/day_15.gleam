import aoc/internal.{type Coord}
import gleam/bool
import gleam/int
import gleam/iterator
import gleam/list
import gleam/order
import gleam/pair
import gleam/regex
import gleam/result
import gleam/set
import gleam/string

// TEST: actual value is 2_000_000
const row = 10

// TEST: actual value is 4_000_000
const search_area = 20

/// Inclusive range
@internal
pub type Range {
  Range(start: Int, end: Int)
}

// PERF: by using a Range type instead of a Set(Coord), I was able to improve
// performance by about 40% (~14-15s down to ~8-10s).
pub fn part_1(input: String) -> Int {
  let sensors =
    input
    |> internal.lines()
    |> list.filter(fn(line) { !string.is_empty(line) })
    |> list.map(parse_line)
  let beacons =
    sensors
    |> list.map(pair.second)
    |> set.from_list()

  sensors
  |> list.filter_map(fn(pair) {
    let #(sensor, beacon) = pair
    x_range(sensor, beacon, row)
  })
  |> merge_ranges()
  |> list.flat_map(fn(range) {
    use x <- list.map(list.range(from: range.start, to: range.end))
    #(x, row)
  })
  |> set.from_list()
  |> set.difference(minus: beacons)
  |> set.size()
}

pub fn part_2(input: String) -> Int {
  let sensors =
    input
    |> internal.lines()
    |> list.filter(fn(line) { !string.is_empty(line) })
    |> list.map(parse_line)

  let assert Ok(#(x, y)) =
    {
      use y <- iterator.map(iterator.range(from: 0, to: search_area))

      sensors
      |> list.filter_map(fn(pair) {
        let #(sensor, beacon) = pair
        x_range(sensor, beacon, y)
      })
      |> merge_ranges()
    }
    |> iterator.index()
    |> iterator.find_map(fn(pair) {
      let #(ranges, _y) = pair
      case list.length(ranges) > 1 {
        True -> Ok(pair)
        False -> Error(Nil)
      }
    })
    |> result.map(fn(pair) {
      let #(ranges, y) = pair
      let assert [first, second] = ranges
      let assert True = first.end + 1 == second.start - 1
      #(first.end + 1, y)
    })

  int.multiply(x, 4_000_000) |> int.add(y)
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
fn x_range(sensor: Coord, beacon: Coord, over y: Int) -> Result(Range, Nil) {
  let distance = manhattan_distance(from: sensor, to: beacon)
  let y_distance_to_target_row = int.absolute_value(sensor.1 - y)
  let x_distance_leftover =
    int.absolute_value(distance - y_distance_to_target_row)
  let is_out_of_range = y_distance_to_target_row > distance

  use <- bool.guard(return: Error(Nil), when: is_out_of_range)
  Ok(Range(
    start: sensor.0 - x_distance_leftover,
    end: sensor.0 + x_distance_leftover,
  ))
}

@internal
pub fn merge_ranges(ranges: List(Range)) -> List(Range) {
  // 1. Sort list of ranges
  // 2. Make a queue of new ranges (to be turned into the returned list)

  let sorted_ranges =
    list.sort(ranges, by: fn(a, b) {
      let start_order = int.compare(a.start, b.start)
      let end_order = int.compare(a.end, b.end)
      start_order |> order.break_tie(with: end_order)
    })

  do_merge_ranges(sorted_ranges, [])
}

fn do_merge_ranges(ranges: List(Range), stack: List(Range)) -> List(Range) {
  // assume list is already sorted

  case ranges, stack {
    // no more ranges to merge
    [], _ -> stack |> list.reverse()
    [first, ..rest], [] -> do_merge_ranges(rest, [first])
    [next_range, ..rest], [prev_range, ..stack] -> {
      let should_merge = next_range.start <= prev_range.end + 1
      case should_merge {
        True -> {
          let min_start = int.min(prev_range.start, next_range.start)
          let max_end = int.max(prev_range.end, next_range.end)
          let new_range = Range(start: min_start, end: max_end)
          do_merge_ranges(rest, [new_range, ..stack])
        }
        False -> do_merge_ranges(rest, [next_range, prev_range, ..stack])
      }
    }
  }
}
