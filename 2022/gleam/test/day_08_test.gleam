import day_08
import gleeunit/should

const example = "30373
25512
65332
33549
35390
"

pub fn part_1_test() {
  example
  |> day_08.part_1()
  |> should.equal(21)
}

pub fn part_2_test() {
  example
  |> day_08.part_2()
  |> should.equal(8)
}
