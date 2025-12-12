///|
fn main {
  let input = try! @fs.read_file_to_string("cmd/day04/input/large.txt")
  println("Part 1: \{input |> parse |> part1}")
  println("Part 2: \{input |> parse |> part2}")
}

///|
fn parse(input : String) -> Array[Array[Char]] {
  input.trim_space().split("\n").map(line => line.iter().to_array()).to_array()
}

///|
struct RemoveResult {
  new_grid : Array[Array[Char]]
  removed : UInt
}

///|
fn remove_rolls_of_paper(grid : Array[Array[Char]]) -> RemoveResult {
  let new_grid = grid.map(row => row.copy())
  let mut removed = 0U
  for i, row in grid {
    for j, c in row {
      let mut adj = 0
      for di in -1..=1 {
        for dj in -1..=1 {
          if (di, dj) == (0, 0) {
            continue
          }
          let (ni, nj) = (i + di, j + dj)
          if 0 <= ni &&
            ni < grid.length() &&
            0 <= nj &&
            nj < grid[ni].length() &&
            grid[ni][nj] == '@' {
            adj += 1
          }
        }
      }
      if c == '@' && adj < 4 {
        new_grid[i][j] = '.'
        removed += 1
      } else {
        new_grid[i][j] = c
      }
    }
  }
  { new_grid, removed }
}

///|
fn part1(grid : Array[Array[Char]]) -> UInt {
  remove_rolls_of_paper(grid).removed
}

///|
fn part2(grid : Array[Array[Char]]) -> UInt {
  let mut grid = grid
  let mut total_removed = 0U
  for {
    let { new_grid, removed } = remove_rolls_of_paper(grid)
    if removed == 0 {
      break
    }
    grid = new_grid
    total_removed += removed
  }
  total_removed
}

///|
test "test_part1" {
  let input = try! @fs.read_file_to_string("cmd/day04/input/small.txt")
  let expected = try! @fs.read_file_to_string(
    "cmd/day04/output/small/part1.txt",
  )
  let actual = input |> parse |> part1
  assert_eq(actual.to_string()[:], expected.trim_space())
}

///|
test "test_part2" {
  let input = try! @fs.read_file_to_string("cmd/day04/input/small.txt")
  let expected = try! @fs.read_file_to_string(
    "cmd/day04/output/small/part2.txt",
  )
  let actual = input |> parse |> part2
  assert_eq(actual.to_string()[:], expected.trim_space())
}
