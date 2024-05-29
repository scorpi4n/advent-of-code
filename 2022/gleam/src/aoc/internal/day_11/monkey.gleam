import aoc/internal
import gleam/int
import gleam/list
import gleam/queue.{type Queue}
import gleam/result
import gleam/string

pub type Monkey {
  Monkey(
    items: Queue(Int),
    operation: fn(Int) -> Int,
    check: fn(Int) -> Int,
    test_factor: Int,
  )
}

pub fn parse(string: String) -> Monkey {
  let assert Ok(#(_, notes)) = string |> string.split_once(on: ":\n")
  let assert [items, operation, ..testing] = notes |> internal.lines()

  let items = {
    let assert Ok(#(_, items)) = items |> string.split_once(on: ": ")
    items
    |> string.split(on: ",")
    |> list.map(fn(s) {
      let assert Ok(n) = string.trim(s) |> int.parse()
      n
    })
    |> queue.from_list()
  }

  let operation = {
    let assert Ok(#(_, operation)) = operation |> string.split_once(on: " = ")
    let assert [_a, op, b] = operation |> string.split(on: " ")

    let b = int.parse(b)
    case op, b {
      "+", Ok(b) -> int.add(_, b)
      "*", Ok(b) -> int.multiply(_, b)
      "*", Error(Nil) -> fn(x) { x * x }
      _, _ -> panic as "unable to parse operation"
    }
  }

  let #(check, divisor) = {
    let assert [divisor, true_case, false_case, ..] = testing
    let assert Ok(divisor) = last_word_of_line_as_int(divisor)
    let assert Ok(true_case) = last_word_of_line_as_int(true_case)
    let assert Ok(false_case) = last_word_of_line_as_int(false_case)

    let check = fn(x) {
      case x % divisor == 0 {
        True -> true_case
        False -> false_case
      }
    }

    #(check, divisor)
  }

  Monkey(items: items, operation: operation, check: check, test_factor: divisor)
}

fn last_word_of_line_as_int(line: String) -> Result(Int, Nil) {
  line |> string.split(on: " ") |> list.last() |> result.try(int.parse)
}

pub fn push(m: Monkey, n: Int) -> Monkey {
  Monkey(..m, items: queue.push_back(n, onto: m.items))
}

pub fn pop(m: Monkey) -> Result(#(Int, Monkey), Nil) {
  use #(n, rest) <- result.map(queue.pop_front(m.items))
  #(n, Monkey(..m, items: rest))
}
