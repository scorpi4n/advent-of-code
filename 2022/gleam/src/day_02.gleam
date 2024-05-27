import gleam/int
import gleam/list
import gleam/string

type Shape {
  Rock
  Paper
  Scissors
}

pub fn part_1(input: String) -> Int {
  input
  |> string.split(on: "\n")
  |> list.filter(fn(line) { !string.is_empty(line) })
  |> list.map(fn(line) {
    let assert Ok(#(opponent, me)) = string.split_once(line, " ")
    let opponent = to_shape(opponent)
    let me = to_shape(me)

    to_int(me) + score_game(me, opponent)
  })
  |> int.sum()
}

pub fn part_2(input: String) -> Int {
  input
  |> string.split(on: "\n")
  |> list.filter(fn(line) { !string.is_empty(line) })
  |> list.map(fn(line) {
    let assert Ok(#(opponent, outcome)) = string.split_once(line, " ")
    let opponent = to_shape(opponent)
    let me = case outcome {
      "X" -> loses_to(opponent)
      "Y" -> opponent
      "Z" -> beats(opponent)
      _ -> panic as "invalid input"
    }

    to_int(me) + score_game(me, opponent)
  })
  |> int.sum()
}

fn to_shape(s: String) -> Shape {
  case s {
    "A" | "X" -> Rock
    "B" | "Y" -> Paper
    "C" | "Z" -> Scissors
    _ -> panic as "invalid input"
  }
}

fn score_game(a: Shape, opponent b: Shape) -> Int {
  case b, a {
    Rock, Rock -> 3
    Rock, Paper -> 6
    Rock, Scissors -> 0
    Paper, Paper -> 3
    Paper, Rock -> 0
    Paper, Scissors -> 6
    Scissors, Scissors -> 3
    Scissors, Rock -> 6
    Scissors, Paper -> 0
  }
}

fn beats(shape: Shape) -> Shape {
  case shape {
    Rock -> Paper
    Paper -> Scissors
    Scissors -> Rock
  }
}

fn loses_to(shape: Shape) -> Shape {
  case shape {
    Rock -> Scissors
    Paper -> Rock
    Scissors -> Paper
  }
}

fn to_int(shape: Shape) -> Int {
  case shape {
    Rock -> 1
    Paper -> 2
    Scissors -> 3
  }
}
