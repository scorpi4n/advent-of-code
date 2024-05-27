import aoc/internal
import gleam/int
import gleam/iterator
import gleam/list
import gleam/pair
import gleam/result
import gleam/set
import gleam/string

type Motion {
  Motion(direction: Direction, step_count: Int)
}

type Direction {
  Up
  Down
  Left
  Right
}

type Coord =
  #(Int, Int)

pub fn part_1(input: String) -> Int {
  let motions =
    input
    |> internal.lines()
    |> list.filter(fn(line) { !string.is_empty(line) })
    |> list.map(fn(line) {
      let assert Ok(motion) = parse(line)
      motion
    })

  motions
  |> list.flat_map(fn(motion) {
    iterator.repeat(Motion(motion.direction, 1))
    |> iterator.take(motion.step_count)
    |> iterator.to_list()
  })
  |> list.scan(from: #(#(0, 0), #(0, 0)), with: fn(coords, motion) {
    let #(head, tail) = coords

    let head = move_head(head, motion)
    let tail = move_tail(head, tail)

    #(head, tail)
  })
  |> list.prepend(#(#(0, 0), #(0, 0)))
  |> list.map(pair.second)
  |> set.from_list()
  |> set.size
}

pub fn part_2(input: String) -> Int {
  let motions =
    input
    |> internal.lines()
    |> list.filter(fn(line) { !string.is_empty(line) })
    |> list.map(fn(line) {
      let assert Ok(motion) = parse(line)
      motion
    })

  motions
  |> list.flat_map(fn(motion) {
    iterator.repeat(Motion(motion.direction, 1))
    |> iterator.take(motion.step_count)
    |> iterator.to_list()
  })
  |> list.scan(
    from: iterator.repeat(#(0, 0))
      |> iterator.take(10)
      |> iterator.to_list(),
    with: fn(coords, motion) {
      let assert [head, ..rest] = coords
      let head = move_head(head, motion)

      rest
      |> list.scan(from: head, with: move_tail)
      |> list.prepend(head)
    },
  )
  |> list.map(fn(rope) {
    // sanity check
    let assert 10 = list.length(rope)
    let assert Ok(last) = list.last(rope)
    last
  })
  |> set.from_list()
  |> set.insert(#(0, 0))
  |> set.size
}

fn parse(string: String) -> Result(Motion, Nil) {
  use #(unparsed_direction, unparsed_count) <- result.try(string.split_once(
    string,
    on: " ",
  ))

  use step_count <- result.try(int.parse(unparsed_count))
  use direction <- result.map(case unparsed_direction {
    "U" -> Ok(Up)
    "D" -> Ok(Down)
    "L" -> Ok(Left)
    "R" -> Ok(Right)
    _ -> Error(Nil)
  })

  Motion(direction, step_count)
}

fn move_head(head: Coord, motion: Motion) -> Coord {
  let #(x, y) = head
  let Motion(direction, step_count) = motion

  case direction {
    Up -> #(x, y + step_count)
    Down -> #(x, y - step_count)
    Left -> #(x - step_count, y)
    Right -> #(x + step_count, y)
  }
}

fn move_tail(head: Coord, tail: Coord) -> Coord {
  let x_delta = head.0 - tail.0
  let y_delta = head.1 - tail.1

  case int.absolute_value(x_delta), int.absolute_value(y_delta) {
    // touching head
    x, y if x <= 1 && y <= 1 -> tail
    // head moved vertically
    x, y if x == 0 && y >= 2 ->
      case y_delta >= 0 {
        True -> #(tail.0, tail.1 + 1)
        False -> #(tail.0, tail.1 - 1)
      }
    // head moved horizontally
    x, y if x >= 2 && y == 0 ->
      case x_delta >= 0 {
        True -> #(tail.0 + 1, tail.1)
        False -> #(tail.0 - 1, tail.1)
      }
    // head is diagonal from tail
    x, y if x >= 2 || y >= 2 ->
      case x_delta >= 0, y_delta >= 0 {
        // Right, Up
        True, True -> #(tail.0 + 1, tail.1 + 1)
        // Right, Down
        True, False -> #(tail.0 + 1, tail.1 - 1)
        // Left, Up
        False, True -> #(tail.0 - 1, tail.1 + 1)
        // Left, Down
        False, False -> #(tail.0 - 1, tail.1 - 1)
      }
    _, _ -> panic
  }
}
