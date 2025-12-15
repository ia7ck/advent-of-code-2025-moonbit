///|
fn main {
  let input = try! @fs.read_file_to_string("cmd/day12/input/large.txt")
  println("Part 1: \{input |> parse |> part1}")
}

///|
struct Input {
  presents : Array[Array[Array[Char]]]
  regions : Array[Region]
} derive(Show, Eq)

///|
struct Region {
  width : Int
  height : Int
  quantity : Array[Int]
} derive(Show, Eq)

///|
fn parse(input : String) -> Input {
  let sections = input.trim_space().split("\n\n").to_array()
  let shapes = sections[:sections.length() - 1].map(parse_present)
  let regions = sections[sections.length() - 1]
    .split("\n")
    .map(parse_region)
    .to_array()
  { presents: shapes, regions }
}

///|
fn parse_present(input : StringView) -> Array[Array[Char]] {
  // drop `1:`, `2:`, ...
  input.split("\n").drop(1).map(l => l.to_array()).to_array()
}

///|
fn parse_region(line : StringView) -> Region {
  let parts = line.split(": ").to_array()
  let wh = parts[0].split("x").to_array()
  let width = try! @strconv.parse_int(wh[0])
  let height = try! @strconv.parse_int(wh[1])
  let quantity = parts[1]
    .split(" ")
    .map(s => try! @strconv.parse_int(s))
    .to_array()
  { width, height, quantity }
}

///|
fn part1(input : Input) -> Int {
  let n = 3
  guard input.presents.iter().all(p => p.length() == n && p[0].length() == n)
  input.regions
  .filter(region => {
    let presents_area = region.quantity
      .mapi((i, q) => {
        let a = input.presents[i].flatten().filter(c => c == '#').length()
        a * q
      })
      .fold(init=0, (acc, area) => acc + area)
    let presents_rectangle_area = region.quantity
      .map(q => {
        let a = n * n
        a * q
      })
      .fold(init=0, (acc, area) => acc + area)
    if region.width * region.height < presents_area {
      // `#` を仮にバラバラにしても個数が多くて領域に入りきらない
      false
    } else if presents_rectangle_area <=
      (region.width - region.width % 3) * (region.height - region.height % 3) {
      // 領域の幅、高さを3の倍数になるように縮めたとしても3x3のプレゼントを敷きつめられる
      true
    } else {
      // ギリギリOK/NGのパターンは存在しない
      abort("unimplemented")
    }
  })
  .length()
}

///|
test "test_parse" {
  let input =
    #|0:
    #|#..
    #|##.
    #|###
    #|
    #|1:
    #|.#.
    #|.#.
    #|###
    #|
    #|5x5: 1 2
    #|10x14: 6 5
  assert_eq(parse(input), {
    presents: [
      [
        // 0:
        ['#', '.', '.'],
        ['#', '#', '.'],
        ['#', '#', '#'],
      ],
      [
        // 1:
        ['.', '#', '.'],
        ['.', '#', '.'],
        ['#', '#', '#'],
      ],
    ],
    regions: [
      { width: 5, height: 5, quantity: [1, 2] },
      { width: 10, height: 14, quantity: [6, 5] },
    ],
  })
}
