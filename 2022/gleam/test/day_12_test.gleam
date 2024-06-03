import day_12
import gleeunit/should

const example = "Sabqponm
abcryxxl
accszExk
acctuvwj
abdefghi
"

pub fn part_1_test() {
  example
  |> day_12.part_1()
  |> should.equal(31)
}

pub fn part_2_test() {
  example
  |> day_12.part_2()
  |> should.equal(29)
}
