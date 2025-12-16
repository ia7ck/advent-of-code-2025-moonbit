///|
fn main {
  let input = try! @fs.read_file_to_string("cmd/day01/input/large.txt")
  println("Part 1: \{input |> parse |> part1}")
  println("Part 2: \{input |> parse |> part2}")
}

///|
struct Rotation {
  direction : Direction
  amount : Int64
}

///|
enum Direction {
  L
  R
}

///|
fn parse(input : String) -> Array[Rotation] {
  input.trim_space().split("\n").map(parse_line).to_array()
}

///|
fn parse_line(line : StringView) -> Rotation {
  if line.strip_prefix("L") is Some(rest) {
    return { direction: Direction::L, amount: try! @strconv.parse_int64(rest) }
  }
  if line.strip_prefix("R") is Some(rest) {
    return { direction: Direction::R, amount: try! @strconv.parse_int64(rest) }
  }
  abort("unimplemented")
}

///|
struct ModInt(Int64) derive(Show)

///|
fn ModInt::is_zero(self : ModInt) -> Bool {
  self.0 == 0
}

///|
impl Add for ModInt with add(self : ModInt, other : ModInt) -> ModInt {
  ((self.0 + other.0) % 100 + 100) % 100
}

///|
impl Sub for ModInt with sub(self : ModInt, other : ModInt) -> ModInt {
  ((self.0 - other.0) % 100 + 100) % 100
}

///|
struct State {
  hit : Int64
  position : ModInt
}

///|
fn part1(rotations : Array[Rotation]) -> Int64 {
  let acc = rotations.fold(init=State::{ hit: 0, position: ModInt(50) }, (
    acc,
    rot,
  ) => {
    let new_position = match rot.direction {
      Direction::L => acc.position - rot.amount
      Direction::R => acc.position + rot.amount
    }
    let new_hit = acc.hit + (if new_position.is_zero() { 1 } else { 0 })
    { hit: new_hit, position: new_position }
  })
  acc.hit
}

///|
fn part2(rotations : Array[Rotation]) -> Int64 {
  rotations
  |> Array::iter()
  |> Iter::flat_map(rot => 0L
    .until(rot.amount)
    .map(_ => Rotation::{ direction: rot.direction, amount: 1 }))
  |> Iter::to_array()
  |> part1
}

///|
test "test_part1" {
  let input = try! @fs.read_file_to_string("cmd/day01/input/small.txt")
  let expected = try! @fs.read_file_to_string(
    "cmd/day01/output/small/part1.txt",
  )
  let actual = input |> parse |> part1
  assert_eq(actual.to_string()[:], expected.trim_space().trim_space())
}

///|
test "test_part2" {
  let input = try! @fs.read_file_to_string("cmd/day01/input/small.txt")
  let expected = try! @fs.read_file_to_string(
    "cmd/day01/output/small/part2.txt",
  )
  let actual = input |> parse |> part2
  assert_eq(actual.to_string()[:], expected.trim_space())
}
