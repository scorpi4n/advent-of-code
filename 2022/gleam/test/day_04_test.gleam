import day_04
import gleeunit/should

const example = "2-4,6-8
2-3,4-5
5-7,7-9
2-8,3-7
6-6,4-6
2-6,4-8
"

pub fn part_1_test() {
  example
  |> day_04.part_1()
  |> should.equal(2)
}

pub fn part_2_test() {
  example
  |> day_04.part_2()
  |> should.equal(4)
}
