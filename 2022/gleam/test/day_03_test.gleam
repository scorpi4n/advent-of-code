import day_03
import gleeunit/should

const example = "vJrwpWtwJgWrhcsFMMfFFhFp
jqHRNqRjqzjGDLGLrsFMfFZSrLrFZsSL
PmmdzqPrVvPwwTWBwg
wMqvLMZHhHMvwLHjbvcjnnSBnvTQFn
ttgJtRGJQctTZtZT
CrZsJsPPZsGzwwsLwLmpwMDw
"

pub fn part_1_test() {
  example
  |> day_03.part_1()
  |> should.equal(157)
}

pub fn part_2_test() {
  example
  |> day_03.part_2()
  |> should.equal(70)
}
