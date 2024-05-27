import day_09
import gleeunit/should

const small_example = "R 4
U 4
L 3
D 1
R 4
D 1
L 5
R 2
"

const large_example = "R 5
U 8
L 8
D 3
R 17
D 10
L 25
U 20
"

pub fn part_1_test() {
  small_example
  |> day_09.part_1()
  |> should.equal(13)
}

pub fn part_2_test() {
  small_example
  |> day_09.part_2()
  |> should.equal(1)

  large_example
  |> day_09.part_2()
  |> should.equal(36)
}
