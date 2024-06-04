import day_13
import gleeunit/should

const example = "[1,1,3,1,1]
[1,1,5,1,1]

[[1],[2,3,4]]
[[1],4]

[9]
[[8,7,6]]

[[4,4],4,4]
[[4,4],4,4,4]

[7,7,7,7]
[7,7,7]

[]
[3]

[[[]]]
[[]]

[1,[2,[3,[4,[5,6,7]]]],8,9]
[1,[2,[3,[4,[5,6,0]]]],8,9]
"

pub fn part_1_test() {
  example
  |> day_13.part_1()
  |> should.equal(13)
}

pub fn part_2_test() {
  example
  |> day_13.part_2()
  |> should.equal(140)
}
