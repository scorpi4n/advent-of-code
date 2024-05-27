import gleam/iterator
import gleam/list.{Continue, Stop}
import gleam/set
import gleam/string

pub fn part_1(input: String) -> Int {
  let marker_size = 4
  solve(input, marker_size)
}

pub fn part_2(input: String) -> Int {
  let marker_size = 14
  solve(input, marker_size)
}

fn solve(input: String, marker_size: Int) -> Int {
  input
  |> string.to_graphemes()
  |> list.window(by: marker_size)
  |> iterator.from_list()
  |> iterator.fold_until(from: marker_size, with: fn(i, window) {
    let all_unique =
      window
      |> set.from_list()
      |> set.size()
      == marker_size

    case all_unique {
      True -> Stop(i)
      False -> Continue(i + 1)
    }
  })
}
