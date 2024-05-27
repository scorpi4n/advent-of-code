import day_02
import gleeunit/should

const example = "A Y
B X
C Z
"

pub fn part_1_test() {
  example
  |> day_02.part_1()
  |> should.equal(15)
}

pub fn part_2_test() {
  example
  |> day_02.part_2()
  |> should.equal(12)
}
