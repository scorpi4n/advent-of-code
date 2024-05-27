import day_01
import gleeunit/should

const example = "1000
2000
3000

4000

5000
6000

7000
8000
9000

10000
"

pub fn part_1_test() {
  example
  |> day_01.part_1()
  |> should.equal(24_000)
}

pub fn part_2_test() {
  example
  |> day_01.part_2()
  |> should.equal(45_000)
}
