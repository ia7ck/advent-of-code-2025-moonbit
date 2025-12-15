///|
fn main {
  let input = try! @fs.read_file_to_string("cmd/day05/input/large.txt")
  println("Part 1: \{input |> parse |> part1}")
  println("Part 2: \{input |> parse |> part2}")
}

///|
struct Input {
  fresh_id_ranges : Array[Range]
  ids : Array[UInt64]
}

///|
struct Range {
  start : UInt64
  end : UInt64
} derive(Show, Eq)

///|
fn parse(input : String) -> Input {
  let sections = input.trim_space().split("\n\n").to_array()
  {
    fresh_id_ranges: parse_fresh_id_ranges(sections[0]),
    ids: parse_ids(sections[1]),
  }
}

///|
fn parse_fresh_id_ranges(input : StringView) -> Array[Range] {
  input
  .split("\n")
  .map(line => {
    let parts = line.split("-").to_array()
    {
      start: try! @strconv.parse_uint64(parts[0]),
      end: try! @strconv.parse_uint64(parts[1]),
    }
  })
  .to_array()
}

///|
fn parse_ids(input : StringView) -> Array[UInt64] {
  input.split("\n").map(line => try! @strconv.parse_uint64(line)).to_array()
}

///|
fn part1(input : Input) -> Int {
  input.ids
  .filter(id => input.fresh_id_ranges
    .iter()
    .any(range => range.start <= id && id <= range.end))
  .length()
}

///|
fn UInt64::min(self : UInt64, other : UInt64) -> UInt64 {
  if self < other {
    self
  } else {
    other
  }
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
fn Range::merge(self : Range, other : Range) -> Range? {
  if self.end + 1 < other.start || other.end + 1 < self.start {
    None
  } else {
    Some({ start: self.start.min(other.start), end: self.end.max(other.end) })
  }
}

///|
fn part2(input : Input) -> UInt64 {
  let ranges = input.fresh_id_ranges.fold(init=[], (acc, r) => {
    let mut r = r
    let new_acc = Array::new()
    for other in acc {
      match r.merge(other) {
        Some(m) => r = m
        None => new_acc.push(other)
      }
    }
    new_acc.push(r)
    new_acc
  })
  ranges.fold(init=0, (acc, r) => acc + (r.end - r.start + 1))
}

///|
test "test_part1" {
  let input = try! @fs.read_file_to_string("cmd/day05/input/small.txt")
  let expected = try! @fs.read_file_to_string(
    "cmd/day05/output/small/part1.txt",
  )
  let actual = input |> parse |> part1
  assert_eq(actual.to_string()[:], expected.trim_space())
}

///|
test "test_merge" {
  // intersect
  inspect(
    Range::{ start: 0, end: 10 }.merge({ start: 5, end: 15 }),
    content="Some({start: 0, end: 15})",
  )

  // contains
  inspect(
    Range::{ start: 0, end: 10 }.merge({ start: 5, end: 8 }),
    content="Some({start: 0, end: 10})",
  )

  // disjoint
  inspect(
    Range::{ start: 0, end: 10 }.merge({ start: 15, end: 20 }),
    content="None",
  )
}

///|
test "test_part2" {
  let input = try! @fs.read_file_to_string("cmd/day05/input/small.txt")
  let expected = try! @fs.read_file_to_string(
    "cmd/day05/output/small/part2.txt",
  )
  let actual = input |> parse |> part2
  assert_eq(actual.to_string()[:], expected.trim_space())
}
