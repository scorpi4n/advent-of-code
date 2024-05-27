import aoc/internal
import gleam/dict.{type Dict}
import gleam/int
import gleam/iterator
import gleam/list
import gleam/option.{None, Some}
import gleam/pair
import gleam/string

type Instruction {
  Instruction(count: Int, from: Int, to: Int)
}

pub fn part_1(input: String) -> String {
  let assert Ok(#(drawing, unparsed_instructions)) =
    input
    |> string.split_once(on: "\n\n")

  let stacks = from_drawing(drawing)
  let instructions =
    unparsed_instructions
    |> internal.lines()
    |> list.filter(fn(line) { !string.is_empty(line) })
    |> list.map(to_instruction)

  let stacks =
    instructions
    |> list.fold(from: stacks, with: fn(stacks, instruction) {
      // follow instruction
      iterator.range(from: 1, to: instruction.count)
      |> iterator.fold(from: stacks, with: fn(stacks, _) {
        // pop off i.from
        let assert Ok([top, ..rest]) = dict.get(stacks, instruction.from)
        dict.insert(stacks, instruction.from, rest)
        // push to i.to
        |> dict.update(instruction.to, with: fn(opt) {
          case opt {
            Some(stack) -> [top, ..stack]
            None -> [top]
          }
        })
      })
    })

  stacks
  |> to_answer_string()
}

pub fn part_2(input: String) -> String {
  let assert Ok(#(drawing, unparsed_instructions)) =
    input
    |> string.split_once(on: "\n\n")

  let stacks = from_drawing(drawing)
  let instructions =
    unparsed_instructions
    |> internal.lines()
    |> list.filter(fn(line) { !string.is_empty(line) })
    |> list.map(to_instruction)

  let stacks =
    instructions
    |> list.fold(from: stacks, with: fn(stacks, instruction) {
      let assert Ok(list) = dict.get(stacks, instruction.from)
      let #(popped, rest) = list.split(list, at: instruction.count)
      dict.insert(stacks, instruction.from, rest)
      |> dict.update(instruction.to, with: fn(opt) {
        case opt {
          Some(stack) -> list.concat([popped, stack])
          None -> popped
        }
      })
    })

  stacks
  |> to_answer_string()
}

fn from_drawing(drawing: String) -> Dict(Int, List(String)) {
  let assert Ok(stacks) =
    drawing
    |> internal.lines()
    |> list.filter(fn(line) { !string.is_empty(line) })
    |> list.reverse()
    |> list.split(1)
    |> pair.second()
    |> list.map(fn(row) {
      row
      |> string.to_graphemes()
      |> list.sized_chunk(4)
      |> list.index_map(fn(chunk, index) {
        let assert [_, char, _, ..] = chunk
        #(char, index + 1)
      })
      |> list.filter(fn(tuple) {
        let #(char, _) = tuple
        char != " "
      })
      |> list.group(fn(tuple) { tuple.1 })
      |> dict.map_values(fn(_, v) { list.map(v, with: pair.first) })
    })
    |> list.reduce(fn(acc, curr) {
      acc
      |> dict.map_values(fn(k, stack) {
        case dict.get(curr, k) {
          Ok(list) -> list.concat([list, stack])
          Error(Nil) -> stack
        }
      })
    })

  stacks
}

fn to_instruction(s: String) -> Instruction {
  let assert [count, from, to] =
    s
    |> string.split(on: " ")
    |> list.filter_map(int.parse)

  Instruction(count, from, to)
}

fn to_answer_string(stacks: Dict(Int, List(String))) -> String {
  stacks
  |> dict.to_list()
  |> list.sort(by: fn(a, b) {
    let key_a = pair.first(a)
    let key_b = pair.first(b)
    int.compare(key_a, with: key_b)
  })
  |> list.map(fn(entry) -> String {
    let assert Ok(first) =
      entry
      |> pair.second()
      |> list.first()

    first
  })
  |> string.join(with: "")
}
