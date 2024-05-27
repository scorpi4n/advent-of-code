import day_07
import gleeunit/should

const example = "$ cd /
$ ls
dir a
14848514 b.txt
8504156 c.dat
dir d
$ cd a
$ ls
dir e
29116 f
2557 g
62596 h.lst
$ cd e
$ ls
584 i
$ cd ..
$ cd ..
$ cd d
$ ls
4060174 j
8033020 d.log
5626152 d.ext
7214296 k
"

pub fn part_1_test() {
  example
  |> day_07.part_1()
  |> should.equal(95_437)
}

pub fn part_2_test() {
  example
  |> day_07.part_2()
  |> should.equal(24_933_642)
}

pub fn nesting_test() {
  "$ cd /
$ ls
dir a
$ cd a
$ ls
dir b
100 text
$ cd b
$ ls
123 abc
456 songs.txt
"
  // /
  // - a
  //   - text 100
  //   - b
  //     - abc 123
  //     - songs.txt 456
  |> day_07.part_1()
  |> should.equal(1937)
}
