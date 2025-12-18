///|
fn main {
  let input = try! @fs.read_file_to_string("cmd/day03/input/large.txt")
  println("Part 1: \{input |> parse |> part1}")
  println("Part 2: \{input |> parse |> part2}")
  println("Part 2: \{input |> parse |> part2_greedy}")
}

///|
fn parse(input : String) -> Array[Array[UInt64]] {
  input.trim_space().split("\n").map(parse_line).to_array()
}

///|
fn parse_line(line : StringView) -> Array[UInt64] {
  line
  .iter()
  .map(c => UInt::to_uint64(Char::to_uint(c) - Char::to_uint('0')))
  .to_array()
}

///|
fn UInt64::max(self : UInt64, other : UInt64) -> UInt64 {
  if self > other {
    self
  } else {
    other
  }
}

///|
fn part1(banks : Array[Array[UInt64]]) -> UInt64 {
  banks
  .map(b => {
    let mut largest_joltage = 0UL
    for i in 0..<b.length() {
      for j in (i + 1)..<b.length() {
        let joltage = b[i] * 10 + b[j]
        largest_joltage = largest_joltage.max(joltage)
      }
    }
    largest_joltage
  })
  .fold(init=0, (acc, j) => acc + j)
}

///|
fn part2(banks : Array[Array[UInt64]]) -> UInt64 {
  banks
  .map(b => {
    let largest_joltage = FixedArray::make(13, None)
    largest_joltage[0] = Some(0UL)
    for b in b {
      for len in (11).until(0, step=-1, inclusive=true) {
        if largest_joltage[len] is Some(joltage) {
          let new_joltage = joltage * 10 + b
          largest_joltage[len + 1] = match largest_joltage[len + 1] {
            Some(j) => Some(j.max(new_joltage))
            None => Some(new_joltage)
          }
        }
      }
    }
    largest_joltage[12].unwrap()
  })
  .fold(init=0, (acc, j) => acc + j)
}

///|
fn part2_greedy(banks : Array[Array[UInt64]]) -> UInt64 {
  banks
  .map(b => {
    let largest_joltage = Array::new()
    let mut i = 0
    while largest_joltage.length() < 12 {
      // UInt64 には .until() がない
      let new_i = [9UL, 8, 7, 6, 5, 4, 3, 2, 1]
        .iter()
        .filter_map(d => {
          let b = b[i:].to_array()
          b.search(d).map(p => i + p)
        })
        .filter(new_i => largest_joltage.length() + (b.length() - new_i) >= 12)
        .head()
        .unwrap()
      largest_joltage.push(b[new_i])
      i = new_i + 1
    }
    try! @strconv.parse_uint64(largest_joltage.map(j => j.to_string()).join(""))
  })
  .fold(init=0, (acc, j) => acc + j)
}

///|
test "test_part1" {
  let input = try! @fs.read_file_to_string("cmd/day03/input/small.txt")
  let expected = try! @fs.read_file_to_string(
    "cmd/day03/output/small/part1.txt",
  )
  let actual = input |> parse |> part1
  assert_eq(actual.to_string()[:], expected.trim_space())
}

///|
test "test_part2" {
  let input = try! @fs.read_file_to_string("cmd/day03/input/small.txt")
  let expected = try! @fs.read_file_to_string(
    "cmd/day03/output/small/part2.txt",
  )
  let actual = input |> parse |> part2
  assert_eq(actual.to_string()[:], expected.trim_space())
}

///|
test "test_part2_greedy" {
  let input = try! @fs.read_file_to_string("cmd/day03/input/small.txt")
  let expected = try! @fs.read_file_to_string(
    "cmd/day03/output/small/part2.txt",
  )
  let actual = input |> parse |> part2_greedy
  assert_eq(actual.to_string()[:], expected.trim_space())
}
