import aoc/internal/day_11/monkey.{Monkey}
import gleam/dict
import gleam/int
import gleam/iterator
import gleam/list.{Continue, Stop}
import gleam/option.{Some}
import gleam/order
import gleam/pair
import gleam/queue
import gleam/string

pub fn part_1(input: String) -> Int {
  let initial_monkeys =
    input
    |> string.split("\n\n")
    |> list.filter(fn(line) { !string.is_empty(line) })
    |> list.map(monkey.parse)
    |> list.index_map(fn(m, i) { #(i, m) })
    |> dict.from_list()

  iterator.single(list.range(from: 0, to: dict.size(initial_monkeys) - 1))
  |> iterator.cycle()
  |> iterator.take(20)
  |> iterator.fold(from: #(initial_monkeys, dict.new()), with: fn(acc, round) {
    use #(monkeys, inspections), id <- list.fold(over: round, from: acc)

    let inspections = {
      let assert Ok(m) = dict.get(monkeys, id)
      use count <- dict.update(id, in: inspections)
      count |> option.unwrap(or: 0) |> int.add(queue.length(m.items))
    }

    let monkeys =
      iterator.repeat(Nil)
      |> iterator.fold_until(from: monkeys, with: fn(monkeys, _) {
        let assert Ok(m) = dict.get(monkeys, id)

        case m.items |> queue.to_list() {
          [] -> Stop(monkeys)
          [front, ..rest] -> {
            let assert Ok(item) = front |> m.operation() |> int.divide(3)
            let throw_to = m.check(item)

            monkeys
            |> dict.insert(id, Monkey(..m, items: queue.from_list(rest)))
            |> dict.update(throw_to, fn(receiving) {
              let assert Some(receiving) = receiving
              receiving |> monkey.push(item)
            })
            |> Continue
          }
        }
      })

    #(monkeys, inspections)
  })
  |> pair.second()
  |> dict.values()
  |> list.sort(by: order.reverse(int.compare))
  |> list.take(2)
  |> int.product()
}

pub fn part_2(input: String) -> Int {
  let initial_monkeys =
    input
    |> string.split("\n\n")
    |> list.filter(fn(line) { !string.is_empty(line) })
    |> list.map(monkey.parse)
    |> list.index_map(fn(m, i) { #(i, m) })
    |> dict.from_list()

  let modulus =
    initial_monkeys
    |> dict.values()
    |> list.map(fn(m) { m.test_factor })
    |> int.product()

  iterator.single(list.range(from: 0, to: dict.size(initial_monkeys) - 1))
  |> iterator.cycle()
  |> iterator.take(10_000)
  |> iterator.fold(from: #(initial_monkeys, dict.new()), with: fn(acc, round) {
    use #(monkeys, inspections), id <- list.fold(over: round, from: acc)

    let inspections = {
      let assert Ok(m) = dict.get(monkeys, id)
      use count <- dict.update(id, in: inspections)
      count |> option.unwrap(or: 0) |> int.add(queue.length(m.items))
    }

    let monkeys =
      iterator.repeat(Nil)
      |> iterator.fold_until(from: monkeys, with: fn(monkeys, _) {
        let assert Ok(m) = dict.get(monkeys, id)

        case m.items |> queue.to_list() {
          [] -> Stop(monkeys)
          [front, ..rest] -> {
            let assert Ok(item) = front |> m.operation() |> int.modulo(modulus)
            let throw_to = m.check(item)

            monkeys
            |> dict.insert(id, Monkey(..m, items: queue.from_list(rest)))
            |> dict.update(throw_to, fn(receiving) {
              let assert Some(receiving) = receiving
              receiving |> monkey.push(item)
            })
            |> Continue
          }
        }
      })

    #(monkeys, inspections)
  })
  |> pair.second()
  |> dict.values()
  |> list.sort(by: order.reverse(int.compare))
  |> list.take(2)
  |> int.product()
}
