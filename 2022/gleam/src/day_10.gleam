import aoc/internal
import gleam/dict.{type Dict}
import gleam/int
import gleam/iterator
import gleam/list
import gleam/pair
import gleam/string
import gleam/string_builder

const initial_x = 1

pub fn part_1(input: String) -> Int {
  let clock =
    input
    |> internal.lines()
    |> list.filter(fn(line) { !string.is_empty(line) })
    |> list.scan(from: #(initial_x, 1), with: fn(acc, line) {
      let #(current_x, cycle_n) = acc
      case line {
        "noop" -> #(current_x, cycle_n + 1)
        "addx " <> unparsed_x -> {
          let assert Ok(v) = int.parse(unparsed_x)
          #(current_x + v, cycle_n + 2)
        }
        _ -> panic as "invalid input"
      }
    })
    |> list.map(pair.swap)
    |> dict.from_list()

  indices()
  |> list.map(fn(i) {
    always_get(i, clock)
    |> int.multiply(i)
  })
  |> int.sum()
}

pub fn part_2(input: String) -> String {
  let clock =
    input
    |> internal.lines()
    |> list.filter(fn(line) { !string.is_empty(line) })
    |> list.scan(from: #(initial_x, 1), with: fn(acc, line) {
      let #(current_x, cycle_n) = acc
      case line {
        "noop" -> #(current_x, cycle_n + 1)
        "addx " <> unparsed_x -> {
          let assert Ok(v) = int.parse(unparsed_x)
          #(current_x + v, cycle_n + 2)
        }
        _ -> panic as "invalid input"
      }
    })
    |> list.map(pair.swap)
    |> dict.from_list()

  iterator.range(from: 1, to: 240)
  |> iterator.fold(from: string_builder.new(), with: fn(str, cycle_n) {
    let x = always_get(cycle_n, clock)
    let pixel_n = { cycle_n - 1 } % 40

    let pixel = case list.contains([x - 1, x, x + 1], pixel_n) {
      True -> "#"
      False -> "."
    }

    str
    |> string_builder.append(pixel)
    |> string_builder.append(case pixel_n {
      39 -> "\n"
      _ -> ""
    })
  })
  |> string_builder.to_string()
}

fn indices() -> List(Int) {
  iterator.iterate(from: 20, with: int.add(_, 40))
  |> iterator.take(6)
  |> iterator.to_list()
}

fn always_get(n: Int, from: Dict(Int, Int)) -> Int {
  case n {
    0 -> 1
    n ->
      case dict.get(from, n) {
        Ok(x) -> x
        Error(Nil) -> always_get(n - 1, from)
      }
  }
}
