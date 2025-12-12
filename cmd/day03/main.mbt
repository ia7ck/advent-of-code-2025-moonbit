///|
fn main {
  let input = try! @fs.read_file_to_string("cmd/day03/input/large.txt")
  println("Part 1: \{input |> parse |> part1}")
  println("Part 2: \{input |> parse |> part2}")
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
  banks.fold(init=0, (acc, b) => {
    let mut largest_joltage = 0UL
    for i in 0..<b.length() {
      for j in (i + 1)..<b.length() {
        let joltage = b[i] * 10 + b[j]
        largest_joltage = largest_joltage.max(joltage)
      }
    }
    acc + largest_joltage
  })
}

///|
fn part2(banks : Array[Array[UInt64]]) -> UInt64 {
  banks.fold(init=0, (acc, b) => {
    let largest_joltage = FixedArray::make(13, None)
    largest_joltage[0] = Some(0UL)
    for b in b {
      for len = 11; len >= 0; len = len - 1 {
        if largest_joltage[len] is Some(joltage) {
          let new_joltage = joltage * 10 + b
          largest_joltage[len + 1] = match largest_joltage[len + 1] {
            Some(j) => Some(j.max(new_joltage))
            None => Some(new_joltage)
          }
        }
      }
    }
    acc + largest_joltage[12].unwrap()
  })
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
