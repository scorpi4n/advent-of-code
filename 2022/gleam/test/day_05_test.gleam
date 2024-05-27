import day_05
import gleeunit/should

const example = "    [D]
[N] [C]
[Z] [M] [P]
 1   2   3

move 1 from 2 to 1
move 3 from 1 to 3
move 2 from 2 to 1
move 1 from 1 to 2
"

pub fn part_1_test() {
  example
  |> day_05.part_1()
  |> should.equal("CMZ")
}

pub fn part_2_test() {
  example
  |> day_05.part_2()
  |> should.equal("MCD")
}
