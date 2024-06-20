import gleam/string

/// Represents an (x, y) coordinate
pub type Coord =
  #(Int, Int)

pub fn lines(string: String) -> List(String) {
  string
  |> string.split(on: "\n")
}
