import gleam/dict.{type Dict}
import gleam/int
import gleam/list
import gleam/option.{None, Some}

pub opaque type FileSystem {
  FileSystem(files: Dict(String, Int), directories: Dict(String, FileSystem))
}

pub type Item {
  File(name: String, size: Int)
  Directory(name: String)
}

pub fn new() -> FileSystem {
  FileSystem(files: dict.new(), directories: dict.new())
}

pub fn insert(
  into fs: FileSystem,
  this item: Item,
  at path: List(String),
) -> FileSystem {
  case path {
    [] -> {
      case item {
        File(name, size) ->
          FileSystem(
            ..fs,
            files: fs.files
              |> dict.insert(name, size),
          )
        Directory(name) ->
          FileSystem(
            ..fs,
            directories: fs.directories
              |> dict.insert(name, new()),
          )
      }
    }
    [subdir, ..rest] -> {
      FileSystem(
        ..fs,
        directories: fs.directories
          |> dict.update(subdir, with: fn(option) {
            case option {
              Some(subdir) -> insert(subdir, item, rest)
              None -> insert(new(), item, rest)
            }
          }),
      )
    }
  }
}

pub fn directory_sizes(fs: FileSystem) -> List(Int) {
  let subdirectories =
    fs.directories
    |> dict.values()
    |> list.flat_map(directory_sizes)

  [sum_file_sizes(fs), ..subdirectories]
}

pub fn sum_file_sizes(fs: FileSystem) -> Int {
  let subdir_sum =
    fs.directories
    |> dict.values()
    |> list.map(sum_file_sizes)
    |> int.sum()
  let files_sum =
    fs.files
    |> dict.values()
    |> int.sum()

  subdir_sum + files_sum
}
