import day_06
import gleam/list
import gleeunit/should

const part_1_examples = [
  #("mjqjpqmgbljsphdztnvjfqwrcgsmlb", 7),
  #("bvwbjplbgvbhsrlpgdmjqwftvncz", 5),
  #("nppdvjthqldpwncqszvftbrmjlhg", 6),
  #("nznrnfrfntjfmvfwmzdfjlvtqnbhcprsg", 10),
  #("zcfzfwzzqfrljwzlrfnpqdbhtmscgvjw", 11),
]

const part_2_examples = [
  #("mjqjpqmgbljsphdztnvjfqwrcgsmlb", 19),
  #("bvwbjplbgvbhsrlpgdmjqwftvncz", 23),
  #("nppdvjthqldpwncqszvftbrmjlhg", 23),
  #("nznrnfrfntjfmvfwmzdfjlvtqnbhcprsg", 29),
  #("zcfzfwzzqfrljwzlrfnpqdbhtmscgvjw", 26),
]

pub fn part_1_test() {
  part_1_examples
  |> list.map(fn(pair) {
    let #(example, answer) = pair

    example
    |> day_06.part_1()
    |> should.equal(answer)
  })
}

pub fn part_2_test() {
  part_2_examples
  |> list.map(fn(pair) {
    let #(example, answer) = pair

    example
    |> day_06.part_2()
    |> should.equal(answer)
  })
}
