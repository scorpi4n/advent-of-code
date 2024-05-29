import day_11 as today
import gleam/int
import gleam/io
import simplifile

pub fn main() {
  // Update in.txt at the project root with the correct puzzle input
  let assert Ok(input) = simplifile.read("in.txt")

  let answer_1 =
    input
    |> today.part_1()
    |> int.to_string()
  io.println("Part 1: " <> answer_1)

  let answer_2 =
    input
    |> today.part_2()
    |> int.to_string()
  io.print("Part 2: " <> answer_2)
}
