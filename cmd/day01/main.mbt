///|
fn main {
  let input = try! @fs.read_file_to_string("cmd/day01/input/large.txt")
  println("Part 1: \{input |> parse |> part1}")
  println("Part 1: \{input |> parse |> part2}")
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
  input.split("\n").map(parseLine).to_array()
}

///|
fn parseLine(line : StringView) -> Rotation {
  match line.strip_prefix("L") {
    Some(rest) =>
      return {
        direction: Direction::L,
        amount: try! @strconv.parse_int64(rest),
      }
    None => ignore(())
  }
  match line.strip_prefix("R") {
    Some(rest) =>
      return {
        direction: Direction::R,
        amount: try! @strconv.parse_int64(rest),
      }
    None => ignore(())
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
    let newPosition = match rot.direction {
      Direction::L => acc.position - rot.amount
      Direction::R => acc.position + rot.amount
    }
    let newHit = acc.hit + (if newPosition.is_zero() { 1 } else { 0 })
    { hit: newHit, position: newPosition }
  })
  acc.hit
}

///|
fn part2(rotations : Array[Rotation]) -> Int64 {
  let acc = rotations.fold(init=State::{ hit: 0, position: ModInt(50) }, (
    acc,
    rot,
  ) => {
    let mut hit = acc.hit
    let mut position = acc.position
    for i in 0L..<rot.amount {
      let p = match rot.direction {
        Direction::L => position - 1L
        Direction::R => position + 1L
      }
      if p.is_zero() {
        hit += 1
      }
      position = p
    }
    { hit, position }
  })
  acc.hit
}

///|
test "test_part1" {
  let input = try! @fs.read_file_to_string("cmd/day01/input/small.txt")
  let expected = try! @fs.read_file_to_string(
    "cmd/day01/output/small/part1.txt",
  )
  let actual = input |> parse |> part1
  assert_eq(actual.to_string(), expected)
}

///|
test "test_part2" {
  let input = try! @fs.read_file_to_string("cmd/day01/input/small.txt")
  let expected = try! @fs.read_file_to_string(
    "cmd/day01/output/small/part2.txt",
  )
  let actual = input |> parse |> part2
  assert_eq(actual.to_string(), expected)
}
