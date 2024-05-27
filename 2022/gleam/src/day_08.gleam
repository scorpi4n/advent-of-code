import aoc/internal
import gleam/dict.{type Dict}
import gleam/int
import gleam/list.{Continue, Stop}
import gleam/order.{Eq, Gt, Lt}
import gleam/result
import gleam/string

pub fn part_1(input: String) -> Int {
  let matrix = from_string(input)
  let #(row_width, col_height) = size(matrix)
  let perimeter = { row_width + col_height - 2 } * 2

  matrix
  |> without_perimeter()
  |> dict.map_values(fn(y, row) {
    dict.filter(row, fn(x, height) {
      let #(north, east, south, west) =
        cardinal_directions_from(x, y, in: matrix)

      [north, east, south, west]
      |> list.any(fn(direction) {
        list.all(
          satisfying: fn(member_height) { member_height < height },
          in: direction,
        )
      })
    })
  })
  |> dict.fold(from: 0, with: fn(acc, _, row) { acc + dict.size(row) })
  |> int.add(perimeter)
}

pub fn part_2(input: String) -> Int {
  let matrix = from_string(input)

  let assert Ok(max_scenic_score) =
    matrix
    |> without_perimeter()
    |> dict.map_values(fn(y, row) {
      dict.map_values(row, fn(x, height) {
        let #(north, east, south, west) =
          cardinal_directions_from(x, y, in: matrix)
        let north = list.reverse(north)
        let west = list.reverse(west)

        let scenic_score =
          [north, west, south, east]
          |> list.map(fn(direction) {
            list.fold_until(from: [], over: direction, with: fn(acc, h) {
              case int.compare(h, height) {
                Lt -> Continue([h, ..acc])
                Gt | Eq -> Stop([h, ..acc])
              }
            })
            |> list.length()
          })
          |> int.product()

        scenic_score
      })
    })
    |> dict.values()
    |> list.flat_map(fn(row) { dict.values(row) })
    |> list.reduce(fn(acc, curr) { int.max(acc, curr) })

  max_scenic_score
}

type Matrix =
  Dict(Int, Dict(Int, Int))

fn from_string(string: String) -> Matrix {
  string
  |> string.trim()
  |> internal.lines()
  |> list.index_map(fn(line, y) {
    let row =
      line
      |> string.to_graphemes()
      |> list.index_map(fn(char, x) {
        let assert Ok(height) = int.parse(char)

        #(x, height)
      })
      |> dict.from_list()

    #(y, row)
  })
  |> dict.from_list()
}

fn without_perimeter(matrix: Matrix) -> Matrix {
  let #(width, height) = size(matrix)

  matrix
  |> dict.take(list.range(from: 1, to: height - 2))
  |> dict.map_values(fn(_, row) {
    dict.take(list.range(from: 1, to: width - 2), from: row)
  })
}

fn size(of matrix: Matrix) -> #(Int, Int) {
  let width = dict.size(matrix)
  let height = case dict.values(matrix) {
    [v, ..] -> dict.size(v)
    [] -> 0
  }

  #(width, height)
}

fn get(x column: Int, y row: Int, from matrix: Matrix) -> Result(Int, Nil) {
  use r <- result.try(dict.get(matrix, row))
  dict.get(r, column)
}

fn cardinal_directions_from(
  x column: Int,
  y row: Int,
  in matrix: Matrix,
) -> #(List(Int), List(Int), List(Int), List(Int)) {
  let #(row_width, col_height) = size(matrix)

  let map_get = list.filter_map(_, fn(coord) {
    let #(x, y) = coord
    get(x, y, matrix)
  })

  let #(west, east) = {
    let assert #(left, [_, ..right]) =
      list.range(from: 0, to: row_width)
      |> list.map(fn(col_n) { #(col_n, row) })
      |> list.split_while(fn(coord) { coord != #(column, row) })

    #(map_get(left), map_get(right))
  }

  let #(north, south) = {
    let assert #(up, [_, ..down]) =
      list.range(from: 0, to: col_height - 1)
      |> list.map(fn(row_n) { #(column, row_n) })
      |> list.split_while(fn(coord) { coord != #(column, row) })

    #(map_get(up), map_get(down))
  }

  #(north, east, south, west)
}
