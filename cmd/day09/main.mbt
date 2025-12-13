///|
fn main {
  let input = try! @fs.read_file_to_string("cmd/day09/input/large.txt")
  println("Part 1: \{input |> parse |> part1}")
  println("Part 2: \{input |> parse |> part2}")
}

///|
struct Tile {
  col : Int64
  row : Int64
} derive(Show, Eq)

///|
fn Tile::area(self : Tile, other : Tile) -> Int64 {
  let width = (self.col - other.col).abs() + 1
  let height = (self.row - other.row).abs() + 1
  width * height
}

///|
fn parse(input : String) -> Array[Tile] {
  input.trim_space().split("\n").map(parse_line).to_array()
}

///|
fn parse_line(line : StringView) -> Tile {
  let parts = line.split(",").to_array()
  let col = try! @strconv.parse_int64(parts[0])
  let row = try! @strconv.parse_int64(parts[1])
  { col, row }
}

///|
fn Int64::min(self : Int64, other : Int64) -> Int64 {
  if self < other {
    self
  } else {
    other
  }
}

///|
fn Int64::max(self : Int64, other : Int64) -> Int64 {
  if self > other {
    self
  } else {
    other
  }
}

///|
fn part1(tiles : Array[Tile]) -> Int64 {
  let mut largest_area = 0L
  for t1 in tiles {
    for t2 in tiles {
      largest_area = largest_area.max(t1.area(t2))
    }
  }
  largest_area
}

///|
fn part2(tiles : Array[Tile]) -> Int64 {
  struct VerticalLine {
    col : Int64
    row_start : Int64
    row_end : Int64
  }
  struct HorizontalLine {
    row : Int64
    col_start : Int64
    col_end : Int64
  }
  fn intersect(v : VerticalLine, h : HorizontalLine) -> Bool {
    h.col_start < v.col &&
    v.col < h.col_end &&
    v.row_start < h.row &&
    h.row < v.row_end
  }

  let vertical_lines = Array::new()
  let horizontal_lines = Array::new()
  for i in 0..<tiles.length() {
    let t1 = tiles[i]
    let t2 = tiles[(i + 1) % tiles.length()]
    if t1.col == t2.col {
      let row_start = t1.row.min(t2.row)
      let row_end = t1.row.max(t2.row)
      vertical_lines.push({ col: t1.col, row_start, row_end })
    }
    if t1.row == t2.row {
      let col_start = t1.col.min(t2.col)
      let col_end = t1.col.max(t2.col)
      horizontal_lines.push({ row: t1.row, col_start, col_end })
    }
  }
  let mut largest_area = 0L
  for t1 in tiles {
    for t2 in tiles {
      let row_start = t1.row.min(t2.row)
      let row_end = t1.row.max(t2.row)
      let col_start = t1.col.min(t2.col)
      let col_end = t1.col.max(t2.col)
      if vertical_lines
        .iter()
        .any(v => intersect(v, { row: row_start, col_start, col_end }) ||
          intersect(v, { row: row_end, col_start, col_end })) {
        continue
      }
      if horizontal_lines
        .iter()
        .any(h => intersect({ col: col_start, row_start, row_end }, h) ||
          intersect({ col: col_end, row_start, row_end }, h)) {
        continue
      }
      let corners = [
        (row_start.to_double() + 0.5, col_start.to_double() + 0.5),
        (row_start.to_double() + 0.5, col_end.to_double() - 0.5),
        (row_end.to_double() - 0.5, col_start.to_double() + 0.5),
        (row_end.to_double() - 0.5, col_end.to_double() - 0.5),
      ]
      if corners
        .iter()
        .all(p => {
          // ray casting
          let (row, col) = p
          let intersections = vertical_lines
            .iter()
            .filter(v => col < v.col.to_double() &&
              v.row_start.to_double() < row &&
              row < v.row_end.to_double())
            .count()
          intersections % 2 == 1
        }) {
        largest_area = largest_area.max(t1.area(t2))
      }
    }
  }
  largest_area
}

///|
test "test_part1" {
  let input = try! @fs.read_file_to_string("cmd/day09/input/small.txt")
  let expected = try! @fs.read_file_to_string(
    "cmd/day09/output/small/part1.txt",
  )
  let actual = input |> parse |> part1
  assert_eq(actual.to_string()[:], expected.trim_space())
}

///|
test "test_part2" {
  let input = try! @fs.read_file_to_string("cmd/day09/input/small.txt")
  let expected = try! @fs.read_file_to_string(
    "cmd/day09/output/small/part2.txt",
  )
  let actual = input |> parse |> part2
  assert_eq(actual.to_string()[:], expected.trim_space())
}
