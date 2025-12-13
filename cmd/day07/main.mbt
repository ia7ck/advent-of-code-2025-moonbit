///|
fn main {
  let input = try! @fs.read_file_to_string("cmd/day07/input/large.txt")
  println("Part 1: \{input |> parse |> part1}")
  println("Part 2: \{input |> parse |> part2}")
}

///|
fn parse(input : String) -> Array[Array[Char]] {
  input.trim_space().split("\n").map(line => line.to_array()).to_array()
}

///|
fn part1(chars : Array[Array[Char]]) -> Int {
  let mut split = 0
  let mut beams = @hashset.HashSet::new()
  let start = chars[0].search('S').unwrap()
  beams.add(start)
  for i in (2).until(chars.length(), step=2) {
    let new_beams = @hashset.HashSet::new()
    for j in beams {
      if chars[i][j] == '^' {
        split += 1
        new_beams.add(j - 1)
        new_beams.add(j + 1)
      } else {
        new_beams.add(j)
      }
    }
    beams = new_beams
  }
  split
}

///|
fn part2(chars : Array[Array[Char]]) -> UInt64 {
  let m = chars[0].length()
  let mut dp = Array::make(m, 0UL)
  let start = chars[0].search('S').unwrap()
  dp[start] = 1
  for i in (2).until(chars.length(), step=2) {
    let new_dp = Array::make(m, 0UL)
    for j in 0..<m {
      if chars[i][j] == '^' {
        new_dp[j - 1] += dp[j]
        new_dp[j + 1] += dp[j]
      } else {
        new_dp[j] += dp[j]
      }
    }
    dp = new_dp
  }
  dp.iter().fold(init=0, (acc, x) => acc + x)
}

///|
test "test_part1" {
  let input = try! @fs.read_file_to_string("cmd/day07/input/small.txt")
  let expected = try! @fs.read_file_to_string(
    "cmd/day07/output/small/part1.txt",
  )
  let actual = input |> parse |> part1
  assert_eq(actual.to_string()[:], expected.trim_space())
}

///|
test "test_part2" {
  let input = try! @fs.read_file_to_string("cmd/day07/input/small.txt")
  let expected = try! @fs.read_file_to_string(
    "cmd/day07/output/small/part2.txt",
  )
  let actual = input |> parse |> part2
  assert_eq(actual.to_string()[:], expected.trim_space())
}
