import aoc/internal
import gleam/int
import gleam/list
import gleam/regex
import gleam/set
import gleam/string

pub fn part_1(input: String) -> Int {
  input
  |> internal.lines()
  |> list.filter(fn(line) { !string.is_empty(line) })
  |> list.map(fn(line) {
    let #(first_half, last_half) =
      line
      |> string.to_graphemes()
      |> list.split(string.length(line) / 2)

    let assert [char] =
      set.intersection(
        of: set.from_list(first_half),
        and: set.from_list(last_half),
      )
      |> set.to_list()

    priority(char)
  })
  |> int.sum()
}

pub fn part_2(input: String) -> Int {
  input
  |> internal.lines()
  |> list.filter(fn(line) { !string.is_empty(line) })
  |> list.sized_chunk(3)
  |> list.map(fn(group) {
    let assert [set_a, set_b, set_c] =
      group
      |> list.map(fn(line) {
        line
        |> string.to_graphemes()
        |> set.from_list()
      })

    let assert [char] =
      set.intersection(of: set_a, and: set_b)
      |> set.intersection(and: set_c)
      |> set.to_list()

    priority(char)
  })
  |> int.sum()
}

fn priority(character: String) -> Int {
  let assert Ok(lowercase) = regex.from_string("[a-z]")

  let assert [codepoint] = string.to_utf_codepoints(character)
  let difference = case regex.check(character, with: lowercase) {
    True -> 96
    False -> 38
  }

  codepoint
  |> string.utf_codepoint_to_int()
  |> int.subtract(difference)
}
