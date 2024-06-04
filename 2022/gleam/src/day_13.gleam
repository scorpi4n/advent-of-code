import gleam/dynamic.{type DecodeErrors, type Dynamic}
import gleam/int
import gleam/json
import gleam/list
import gleam/order.{type Order, Eq, Lt}
import gleam/result
import gleam/string

pub fn part_1(input: String) -> Int {
  input
  |> string.split("\n\n")
  |> list.filter(fn(s) { !string.is_empty(s) })
  |> list.map(fn(unparsed_pair) {
    let assert [first, second] =
      unparsed_pair
      |> string.trim()
      |> string.split(on: "\n")
      |> list.map(parse)

    #(first, second)
  })
  |> list.index_map(fn(pair, i) {
    let order =
      list.map2(pair.0, pair.1, compare)
      // PERF: this list.reduce could be sped up using list.fold_until
      |> list.reduce(order.break_tie)
      |> result.then(fn(order) {
        case order {
          Eq -> Error(Nil)
          _ -> Ok(order)
        }
      })
      |> result.lazy_unwrap(fn() {
        int.compare(list.length(pair.0), list.length(pair.1))
      })

    #(i + 1, order)
  })
  |> list.filter_map(fn(indexed_order) {
    let #(i, order) = indexed_order

    case order {
      Lt -> Ok(i)
      _ -> Error(Nil)
    }
  })
  |> int.sum()
}

pub fn part_2(input: String) -> Int {
  let a = parse("[[2]]")
  let b = parse("[[6]]")
  let divider_packets = [a, b]

  let sorted_packets =
    input
    |> string.split("\n")
    |> list.filter(fn(s) { !string.is_empty(s) })
    |> list.map(parse)
    |> list.append(divider_packets)
    |> list.sort(compare_list)
    |> list.index_map(fn(packet, i) { #(i + 1, packet) })

  let i =
    sorted_packets
    |> list.find_map(fn(indexed_packet) {
      let #(i, packet) = indexed_packet

      case packet == a {
        True -> Ok(i)
        False -> Error(Nil)
      }
    })
    |> result.unwrap(or: 0)

  let j =
    sorted_packets
    |> list.find_map(fn(indexed_packet) {
      let #(i, packet) = indexed_packet

      case packet == b {
        True -> Ok(i)
        False -> Error(Nil)
      }
    })
    |> result.unwrap(or: 0)

  i * j
}

type ListOrInt {
  List(List(ListOrInt))
  Int(Int)
}

fn compare(left: ListOrInt, right: ListOrInt) -> Order {
  case left, right {
    Int(x), Int(y) -> int.compare(x, y)
    List(l), List(r) -> {
      list.map2(l, r, compare)
      |> list.fold(from: Eq, with: order.break_tie)
      |> order.lazy_break_tie(with: fn() {
        int.compare(list.length(l), list.length(r))
      })
    }
    Int(_), List(_) -> compare(List([left]), right)
    List(_), Int(_) -> compare(left, List([right]))
  }
}

fn compare_list(a: List(ListOrInt), b: List(ListOrInt)) -> Order {
  list.map2(a, b, compare)
  |> list.reduce(order.break_tie)
  |> result.then(fn(order) {
    case order {
      Eq -> Error(Nil)
      _ -> Ok(order)
    }
  })
  |> result.lazy_unwrap(fn() { int.compare(list.length(a), list.length(b)) })
}

fn parse(string: String) -> List(ListOrInt) {
  let assert Ok(val) = json.decode(string, using: dynamic.list(of: list_or_int))
  val
}

fn list_or_int(from data: Dynamic) -> Result(ListOrInt, DecodeErrors) {
  data
  |> dynamic.any(of: [
    fn(x) { dynamic.int(x) |> result.map(Int) },
    fn(x) { x |> dynamic.list(of: list_or_int) |> result.map(List) },
  ])
}
