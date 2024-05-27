import gleam/int
import gleam/list
import gleam/order
import gleam/result
import gleam/string

pub fn part_1(input: String) -> Int {
  input
  |> string.split(on: "\n\n")
  |> list.map(fn(group) {
    group
    |> string.split(on: "\n")
    |> list.filter_map(int.parse)
    |> int.sum()
  })
  |> list.reduce(fn(acc, curr) { int.max(acc, curr) })
  |> result.unwrap(or: -1)
}

pub fn part_2(input: String) -> Int {
  input
  |> string.split(on: "\n\n")
  |> list.map(fn(group) {
    group
    |> string.split(on: "\n")
    |> list.filter_map(int.parse)
    |> int.sum()
  })
  |> list.sort(by: order.reverse(int.compare))
  |> list.take(3)
  |> int.sum()
}
