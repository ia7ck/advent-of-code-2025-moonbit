///|
fn main {
  let input = try! @fs.read_file_to_string("cmd/day02/input/large.txt")
  println("Part 1: \{input |> parse |> part1}")
  println("Part 2: \{input |> parse |> part2}")
}

///|
struct Range {
  start : Int64
  end : Int64
} derive(Show, Eq)

///|
fn parse(input : String) -> Array[Range] {
  input.trim_space().split(",").map(parse_range).to_array()
}

///|
fn parse_range(input : StringView) -> Range {
  let parts = input.split("-").to_array()
  {
    start: try! @strconv.parse_int64(parts[0]),
    end: try! @strconv.parse_int64(parts[1]),
  }
}

///|
fn part1(ranges : Array[Range]) -> Int64 {
  ranges
  .iter()
  .flat_map(range => Int64::until(range.start, range.end, inclusive=true))
  .filter(is_invalid_part1)
  .fold(init=0L, (acc, id) => acc + id)
}

///|
fn is_invalid_part1(id : Int64) -> Bool {
  let id = id.to_string()
  let len = id.length()
  try! (id[:len / 2] == id[len / 2:])
}

///|
fn part2(ranges : Array[Range]) -> Int64 {
  ranges
  .iter()
  .flat_map(range => Int64::until(range.start, range.end, inclusive=true))
  .filter(is_invalid_part2)
  .fold(init=0L, (acc, id) => acc + id)
}

///|
fn is_invalid_part2(id : Int64) -> Bool {
  let id = id.to_string()
  let len = id.length()
  (1).until(len)
  .filter(l => len % l == 0)
  .any(l => {
    let pattern = try! id[:l]
    pattern.repeat(len / l) == id
  })
}

///|
test "test_parse" {
  assert_eq(parse("123-456,789-1234"), [
    { start: 123, end: 456 },
    { start: 789, end: 1234 },
  ])
}

///|
test "test_is_invalid_part1" {
  assert_true(is_invalid_part1(123123))
  assert_false(is_invalid_part1(123456))
}

///|
test "test_part1" {
  let input = try! @fs.read_file_to_string("cmd/day02/input/small.txt")
  let expected = try! @fs.read_file_to_string(
    "cmd/day02/output/small/part1.txt",
  )
  let actual = input |> parse |> part1
  assert_eq(actual.to_string()[:], expected.trim_space())
}

///|
test "test_is_invalid_part2" {
  assert_true(is_invalid_part2(123123))
  assert_false(is_invalid_part2(123456))
  assert_true(is_invalid_part2(123123123))
}

///|
test "test_part2" {
  let input = try! @fs.read_file_to_string("cmd/day02/input/small.txt")
  let expected = try! @fs.read_file_to_string(
    "cmd/day02/output/small/part2.txt",
  )
  let actual = input |> parse |> part2
  assert_eq(actual.to_string()[:], expected.trim_space())
}
