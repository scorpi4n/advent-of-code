import aoc/internal
import gleam/bool
import gleam/dict.{type Dict}
import gleam/int
import gleam/iterator
import gleam/list.{Continue, Stop}
import gleam/pair
import gleam/queue.{type Queue}
import gleam/result
import gleam/set.{type Set}
import gleam/string

pub fn part_1(input: String) -> Int {
  let graph =
    input
    |> internal.lines()
    |> list.index_map(fn(line, y) {
      string.to_graphemes(line) |> list.index_map(fn(ch, x) { #(#(x, y), ch) })
    })
    |> list.flatten()
    |> dict.from_list()

  let assert [starting_coord] =
    dict.filter(graph, fn(_k, v) { v == "S" })
    |> dict.to_list()
    |> list.map(pair.first)

  let assert [ending_coord] =
    dict.filter(graph, fn(_k, v) { v == "E" })
    |> dict.to_list()
    |> list.map(pair.first)

  bfs(graph, from: starting_coord, to: ending_coord)
}

pub fn part_2(input: String) -> Int {
  let graph =
    input
    |> internal.lines()
    |> list.index_map(fn(line, y) {
      string.to_graphemes(line) |> list.index_map(fn(ch, x) { #(#(x, y), ch) })
    })
    |> list.flatten()
    |> dict.from_list()

  let assert [ending_coord] =
    dict.filter(graph, fn(_k, v) { v == "E" })
    |> dict.to_list()
    |> list.map(pair.first)

  let assert Ok(shortest_length) =
    dict.filter(graph, fn(_k, v) { v == "S" || v == "a" })
    |> dict.to_list()
    |> list.map(pair.first)
    |> list.map(fn(coord) { bfs(graph, from: coord, to: ending_coord) })
    // NOTE: length == 0 means there was no valid path (I think, this was purely incidental)
    |> list.filter(fn(length) { length != 0 })
    |> list.reduce(int.min)

  shortest_length
}

type Coord =
  #(Int, Int)

fn bfs(
  over graph: Dict(Coord, String),
  from starting_coord: Coord,
  to ending_coord: Coord,
) -> Int {
  let queue = queue.from_list([starting_coord])
  let seen = set.from_list([starting_coord])
  let parents = dict.new()

  do_bfs(graph, ending_coord, queue, seen, parents)
}

fn do_bfs(
  graph: Dict(Coord, String),
  ending_coord: Coord,
  queue: Queue(Coord),
  seen: Set(Coord),
  parents: Dict(Coord, Coord),
) -> Int {
  case queue.pop_front(queue) {
    Error(Nil) ->
      iterator.repeat(Nil)
      |> iterator.fold_until(from: [ending_coord], with: fn(path, _) {
        let assert [coord, ..] = path
        case dict.get(parents, coord) {
          Ok(parent) -> Continue([parent, ..path])
          Error(Nil) -> Stop(path)
        }
      })
      |> list.length()
      |> int.subtract(1)
    Ok(#(first, _)) if first == ending_coord ->
      do_bfs(graph, ending_coord, queue.new(), seen, parents)
    Ok(#(first, rest)) -> {
      let #(queue, seen, parents) =
        neighbors(first)
        |> list.fold(from: #(rest, seen, parents), with: fn(acc, neighbor) {
          // NOTE: I hate this code block, it looks ugly and feels like it could be more idiomatic
          {
            use origin <- result.then(dict.get(graph, first))
            use destination <- result.map(dict.get(graph, neighbor))
            use <- bool.guard(
              when: !is_valid_move(origin, destination)
                || set.contains(seen, neighbor),
              return: acc,
            )
            #(
              queue.push_back(acc.0, neighbor),
              set.insert(acc.1, neighbor),
              dict.insert(acc.2, neighbor, first),
            )
          }
          |> result.unwrap(or: acc)
        })

      do_bfs(graph, ending_coord, queue, seen, parents)
    }
  }
}

fn neighbors(coord: Coord) -> List(Coord) {
  let #(x, y) = coord

  // up, down, left, right
  [#(x - 1, y), #(x + 1, y), #(x, y - 1), #(x, y + 1)]
}

fn is_valid_move(from origin: String, to destination: String) -> Bool {
  let origin = elevation(origin)
  let destination = elevation(destination)

  use <- bool.guard(when: destination <= origin, return: True)
  use <- bool.guard(when: destination == origin + 1, return: True)
  False
}

fn elevation(ch: String) -> Int {
  let assert [codepoint] =
    case ch {
      "S" -> "a"
      "E" -> "z"
      _ -> ch
    }
    |> string.to_utf_codepoints()

  string.utf_codepoint_to_int(codepoint)
}
