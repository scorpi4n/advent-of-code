import day_15.{Range}
import gleeunit/should

const example = "Sensor at x=2, y=18: closest beacon is at x=-2, y=15
Sensor at x=9, y=16: closest beacon is at x=10, y=16
Sensor at x=13, y=2: closest beacon is at x=15, y=3
Sensor at x=12, y=14: closest beacon is at x=10, y=16
Sensor at x=10, y=20: closest beacon is at x=10, y=16
Sensor at x=14, y=17: closest beacon is at x=10, y=16
Sensor at x=8, y=7: closest beacon is at x=2, y=10
Sensor at x=2, y=0: closest beacon is at x=2, y=10
Sensor at x=0, y=11: closest beacon is at x=2, y=10
Sensor at x=20, y=14: closest beacon is at x=25, y=17
Sensor at x=17, y=20: closest beacon is at x=21, y=22
Sensor at x=16, y=7: closest beacon is at x=15, y=3
Sensor at x=14, y=3: closest beacon is at x=15, y=3
Sensor at x=20, y=1: closest beacon is at x=15, y=3
"

pub fn part_1_test() {
  example
  |> day_15.part_1()
  |> should.equal(26)
}

pub fn part_2_test() {
  example
  |> day_15.part_2()
  |> should.equal(56_000_011)
}

pub fn manhattan_distance_test() {
  day_15.manhattan_distance(from: #(2, 18), to: #(-2, 15)) |> should.equal(7)
  day_15.manhattan_distance(from: #(9, 16), to: #(10, 16)) |> should.equal(1)
  day_15.manhattan_distance(from: #(8, 7), to: #(2, 10)) |> should.equal(9)
}

pub fn merge_ranges_test() {
  [
    Range(start: 0, end: 15),
    Range(start: 22, end: 42),
    Range(start: 16, end: 20),
  ]
  |> day_15.merge_ranges()
  |> should.equal([Range(start: 0, end: 20), Range(start: 22, end: 42)])

  [
    Range(12, 12),
    Range(2, 14),
    Range(2, 2),
    Range(-2, 2),
    Range(16, 24),
    Range(14, 18),
  ]
  |> day_15.merge_ranges()
  |> should.equal([Range(-2, 24)])
}
