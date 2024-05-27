import aoc/internal
import aoc/internal/day_07/file_system.{Directory, File}
import gleam/int
import gleam/list
import gleam/queue
import gleam/string

// NOTE: if I were to refactor this, I'd like to use https://hex.pm/packages/filepath

pub fn part_1(input: String) -> Int {
  let #(_, fs) =
    input
    |> internal.lines()
    |> list.filter(fn(line) { !string.is_empty(line) })
    |> list.fold(from: #(queue.new(), file_system.new()), with: fn(acc, line) {
      let #(cwd, fs) = acc

      case line {
        "$ ls" -> acc
        "$ cd /" -> #(queue.new(), fs)
        "$ cd .." -> {
          let assert Ok(#(_, parent_path)) = queue.pop_back(cwd)
          #(parent_path, fs)
        }
        "$ cd " <> subdirectory -> {
          #(queue.push_back(subdirectory, onto: cwd), fs)
        }
        "dir " <> dirname -> {
          let path = queue.to_list(cwd)
          #(cwd, file_system.insert(Directory(dirname), into: fs, at: path))
        }
        unparsed_file -> {
          let assert Ok(#(unparsed_size, name)) =
            string.split_once(unparsed_file, " ")
          let assert Ok(size) = int.parse(unparsed_size)

          let path = queue.to_list(cwd)
          #(cwd, file_system.insert(File(name, size), into: fs, at: path))
        }
      }
    })

  file_system.directory_sizes(fs)
  |> list.filter(fn(size) { size <= 100_000 })
  |> int.sum()
}

pub fn part_2(input: String) -> Int {
  let #(_, fs) =
    input
    |> internal.lines()
    |> list.filter(fn(line) { !string.is_empty(line) })
    |> list.fold(from: #(queue.new(), file_system.new()), with: fn(acc, line) {
      let #(cwd, fs) = acc

      case line {
        "$ ls" -> acc
        "$ cd /" -> #(queue.new(), fs)
        "$ cd .." -> {
          let assert Ok(#(_, parent_path)) = queue.pop_back(cwd)
          #(parent_path, fs)
        }
        "$ cd " <> subdirectory -> {
          #(queue.push_back(subdirectory, onto: cwd), fs)
        }
        "dir " <> dirname -> {
          let path = queue.to_list(cwd)
          #(cwd, file_system.insert(Directory(dirname), into: fs, at: path))
        }
        unparsed_file -> {
          let assert Ok(#(unparsed_size, name)) =
            string.split_once(unparsed_file, " ")
          let assert Ok(size) = int.parse(unparsed_size)

          let path = queue.to_list(cwd)
          #(cwd, file_system.insert(File(name, size), into: fs, at: path))
        }
      }
    })

  let total_space = 70_000_000
  let required_space = 30_000_000
  let used_space = file_system.sum_file_sizes(fs)
  let free_space = total_space - used_space
  let required_space = required_space - free_space

  file_system.directory_sizes(fs)
  |> list.filter(fn(size) { size >= required_space })
  |> list.fold(from: total_space, with: int.min)
}
