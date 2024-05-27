import gleam/string

pub fn lines(string: String) -> List(String) {
  string
  |> string.split(on: "\n")
}
