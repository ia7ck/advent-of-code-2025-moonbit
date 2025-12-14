///|
fn main {
  let input = try! @fs.read_file_to_string("cmd/day10/input/large.txt")
  println("Part 1: \{input |> parse |> part1}")
  println("Part 2: \{input |> parse |> part2}")
}

///|
struct Machine {
  light : Array[Bool]
  buttons : Array[Array[Int]]
  joltage : Array[Int]
} derive(Show, Eq)

///|
fn parse(input : String) -> Array[Machine] {
  input.trim_space().split("\n").map(parse_line).to_array()
}

///|
fn parse_line(line : StringView) -> Machine {
  let parts = line.split(" ").to_array()
  let light = parse_light(parts[0])
  let buttons = parts[1:parts.length() - 1].iter().map(parse_button).to_array()
  let joltage = parse_joltage(parts[parts.length() - 1])
  { light, buttons, joltage }
}

///|
fn parse_light(input : StringView) -> Array[Bool] {
  input
  .trim_start(chars="[")
  .trim_end(chars="]")
  .iter()
  .map(c => match c {
    '#' => true
    '.' => false
    _ => abort("unimplemented")
  })
  .to_array()
}

///|
fn parse_button(input : StringView) -> Array[Int] {
  input
  .trim_start(chars="(")
  .trim_end(chars=")")
  .split(",")
  .map(s => try! @strconv.parse_int(s))
  .to_array()
}

///|
fn parse_joltage(input : StringView) -> Array[Int] {
  input
  .trim_start(chars="{")
  .trim_end(chars="}")
  .split(",")
  .map(s => try! @strconv.parse_int(s))
  .to_array()
}

///|
fn part1(machines : Array[Machine]) -> Int {
  machines
  .map(m => {
    let mut fewest_presses = @int.max_value
    for b in 0..<(1 << m.buttons.length()) {
      let light = Array::make(m.light.length(), false)
      for i in 0..<m.buttons.length() {
        if ((b >> i) & 1) == 1 {
          for j in m.buttons[i] {
            light[j] = !light[j]
          }
        }
      }
      if light == m.light {
        fewest_presses = fewest_presses.min(b.popcnt())
      }
    }
    fewest_presses
  })
  .fold(init=0, (acc, x) => acc + x)
}

///|
/// https://www.reddit.com/r/adventofcode/comments/1pk87hl
fn part2(machines : Array[Machine]) -> Int {
  machines
  .map(m => find_fewest_presses(m.buttons, m.joltage, @hashmap.HashMap::new()).unwrap())
  .fold(init=0, (acc, x) => acc + x)
}

///|
fn find_fewest_presses(
  buttons : Array[Array[Int]],
  joltage : Array[Int],
  memo : @hashmap.HashMap[Array[Int], Int?],
) -> Int? {
  if joltage.iter().all(x => x == 0) {
    return Some(0)
  }
  if memo.get(joltage) is Some(p) {
    return p
  }
  let mut fewest_presses = @int.max_value
  for b in 0..<(1 << buttons.length()) {
    let new_joltage = joltage.copy()
    for i in 0..<buttons.length() {
      if ((b >> i) & 1) == 1 {
        for j in buttons[i] {
          new_joltage[j] -= 1
        }
      }
    }
    if new_joltage.iter().any(x => x < 0) {
      continue
    }
    if new_joltage.iter().any(x => x % 2 == 1) {
      continue
    }
    let new_joltage = new_joltage.iter().map(x => x / 2).to_array()
    if find_fewest_presses(buttons, new_joltage, memo) is Some(p) {
      fewest_presses = fewest_presses.min(p * 2 + b.popcnt())
    }
  }
  let p = if fewest_presses < @int.max_value {
    Some(fewest_presses)
  } else {
    None
  }
  memo.set(joltage, p)
  p
}

///|
test "test_parse" {
  let input = "[#.#.] (0,1) (1) (1,2,3) {10,30,20,20}"
  assert_eq(parse(input), [
    {
      light: [true, false, true, false],
      buttons: [[0, 1], [1], [1, 2, 3]],
      joltage: [10, 30, 20, 20],
    },
  ])
}

///|
test "test_part1" {
  let input = try! @fs.read_file_to_string("cmd/day10/input/small.txt")
  let expected = try! @fs.read_file_to_string(
    "cmd/day10/output/small/part1.txt",
  )
  let actual = input |> parse |> part1
  assert_eq(actual.to_string()[:], expected.trim_space())
}

///|
test "test_part2" {
  let input = try! @fs.read_file_to_string("cmd/day10/input/small.txt")
  let expected = try! @fs.read_file_to_string(
    "cmd/day10/output/small/part2.txt",
  )
  let actual = input |> parse |> part2
  assert_eq(actual.to_string()[:], expected.trim_space())
}
