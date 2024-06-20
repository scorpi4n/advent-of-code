import day_14
import gleeunit/should

const example = "498,4 -> 498,6 -> 496,6
503,4 -> 502,4 -> 502,9 -> 494,9
"

pub fn part_1_test() {
  example
  |> day_14.part_1()
  |> should.equal(24)
}

pub fn part_2_test() {
  example
  |> day_14.part_2()
  |> should.equal(93)
}
