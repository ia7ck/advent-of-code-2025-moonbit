///|
fn main {
  let input = try! @fs.read_file_to_string("cmd/day06/input/large.txt")
  println("Part 1: \{input |> parse_part1 |> part1}")
  println("Part 2: \{input |> parse_part2 |> part2}")
}

///|
struct InputPart1 {
  numbers : Array[Array[UInt64]]
  operators : Array[Op]
} derive(Show, Eq)

///|
enum Op {
  Add
  Multiply
} derive(Show, Eq)

///|
fn parse_part1(input : String) -> InputPart1 {
  let lines = input.trim_space().split("\n").to_array()
  match lines {
    [.. lines, last] => {
      let numbers = lines.map(line => line
        .split(" ")
        .filter(s => s != "")
        .map(s => try! @strconv.parse_uint64(s))
        .to_array())
      let operators = last
        .split(" ")
        .filter(s => s != "")
        .map(op => match op {
          "+" => Op::Add
          "*" => Op::Multiply
          _ => abort("unknown operator")
        })
        .to_array()
      { numbers, operators }
    }
    _ => abort("unimplemented")
  }
}

///|
fn part1(input : InputPart1) -> UInt64 {
  let m = input.operators.length()
  try! assert_true(input.numbers.iter().all(numbers => numbers.length() == m))
  let mut total = 0UL
  for j in 0..<m {
    let mut acc = match input.operators[j] {
      Op::Add => 0UL
      Op::Multiply => 1UL
    }
    for i in 0..<input.numbers.length() {
      let value = input.numbers[i][j]
      match input.operators[j] {
        Op::Add => acc += value
        Op::Multiply => acc *= value
      }
    }
    total += acc
  }
  total
}

///|
fn parse_part2(input : String) -> Array[Array[Char]] {
  input.trim_space().split("\n").map(line => line.to_array()).to_array()
}

///|
fn part2(chars : Array[Array[Char]]) -> UInt64 {
  let n = chars.length()
  let m = chars[0].length()
  let mut total = 0UL
  let numbers = []
  for j = m - 1; j >= 0; j = j - 1 {
    let mut value = 0UL
    for i in 0..<(chars.length() - 1) {
      match chars[i].get(j) {
        Some(c) if c.is_ascii_digit() => {
          let d = UInt::to_uint64(Char::to_uint(c) - Char::to_uint('0'))
          value = value * 10 + d
        }
        _ => ignore(())
      }
    }
    if value > 0 {
      numbers.push(value)
    }
    match chars[n - 1].get(j) {
      Some('+') =>
        total += numbers
          .drain(0, numbers.length())
          .fold(init=0UL, (acc, x) => acc + x)
      Some('*') =>
        total += numbers
          .drain(0, numbers.length())
          .fold(init=1UL, (acc, x) => acc * x)
      _ => ignore(())
    }
  }
  total
}

///|
test "test_parse_part1" {
  let input =
    #|12 34 56
    #| 7  8 9
    #|+   * +
  assert_eq(parse_part1(input), {
    numbers: [[12, 34, 56], [7, 8, 9]],
    operators: [Op::Add, Op::Multiply, Op::Add],
  })
}

///|
test "test_part1" {
  let input = try! @fs.read_file_to_string("cmd/day06/input/small.txt")
  let expected = try! @fs.read_file_to_string(
    "cmd/day06/output/small/part1.txt",
  )
  let actual = input |> parse_part1 |> part1
  assert_eq(actual.to_string()[:], expected.trim_space())
}

///|
test "test_parse_part2" {
  let input =
    #|12 34 56
    #| 7  8 9
    #|+   * +
  assert_eq(parse_part2(input), [
    ['1', '2', ' ', '3', '4', ' ', '5', '6'],
    [' ', '7', ' ', ' ', '8', ' ', '9'],
    ['+', ' ', ' ', ' ', '*', ' ', '+'],
  ])
}

///|
test "test_part2" {
  let input = try! @fs.read_file_to_string("cmd/day06/input/small.txt")
  let expected = try! @fs.read_file_to_string(
    "cmd/day06/output/small/part2.txt",
  )
  let actual = input |> parse_part2 |> part2
  assert_eq(actual.to_string()[:], expected.trim_space())
}
