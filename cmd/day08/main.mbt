///|
fn main {
  let input = try! @fs.read_file_to_string("cmd/day08/input/large.txt")
  println("Part 1: \{input |> parse |> part1(connections=1000)}")
  println("Part 2: \{input |> parse |> part2}")
}

///|
struct JunctionBox {
  x : Int64
  y : Int64
  z : Int64
} derive(Show)

///|
fn JunctionBox::distance(self : JunctionBox, other : JunctionBox) -> Int64 {
  fn pow2(x : Int64) -> Int64 {
    x * x
  }

  pow2(self.x - other.x) + pow2(self.y - other.y) + pow2(self.z - other.z)
}

///|
fn parse(input : String) -> Array[JunctionBox] {
  input.trim_space().split("\n").map(parse_line).to_array()
}

///|
fn parse_line(line : StringView) -> JunctionBox {
  let parts = line.split(",").to_array()
  let x = try! @strconv.parse_int64(parts[0])
  let y = try! @strconv.parse_int64(parts[1])
  let z = try! @strconv.parse_int64(parts[2])
  { x, y, z }
}

///|
fn reachable_junction_boxes(
  start : Int,
  n : Int,
  graph : Array[Array[Int]],
) -> Array[Int] {
  let result = Array::new()
  let seen = Array::make(n, false)
  let que = @queue.Queue::new()
  seen[start] = true
  que.push(start)
  while que.pop() is Some(u) {
    result.push(u)
    for v in graph[u] {
      if seen[v] {
        continue
      }
      seen[v] = true
      que.push(v)
    }
  }
  result
}

///|
fn part1(junction_boxes : Array[JunctionBox], connections~ : Int) -> Int {
  let n = junction_boxes.length()
  let edges = Array::new()
  for i in 0..<n {
    for j in (i + 1)..<n {
      edges.push((i, j))
    }
  }
  edges.sort_by_key(e => junction_boxes[e.0].distance(junction_boxes[e.1]))
  let graph = Array::makei(n, _ => Array::new())
  for e in edges[:connections] {
    let (i, j) = e
    graph[i].push(j)
    graph[j].push(i)
  }
  let circuits = (0).until(n)
    |> Iter::map(i => {
      let boxes = reachable_junction_boxes(i, n, graph)
      boxes.sort()
      boxes
    })
    |> @hashset.from_iter
    |> @hashset.HashSet::to_array
  circuits.sort_by_key(c => c.length())
  circuits.rev_in_place()
  circuits.iter().take(3).fold(init=1, (acc, c) => acc * c.length())
}

///|
fn part2(junction_boxes : Array[JunctionBox]) -> Int64 {
  let n = junction_boxes.length()
  let edges = Array::new()
  for i in 0..<n {
    for j in (i + 1)..<n {
      edges.push((i, j))
    }
  }
  edges.sort_by_key(e => junction_boxes[e.0].distance(junction_boxes[e.1]))
  let graph = Array::makei(n, _ => Array::new())
  for e in edges {
    let (i, j) = e
    graph[i].push(j)
    graph[j].push(i)
    let boxes = reachable_junction_boxes(0, n, graph)
    if boxes.length() == n {
      return junction_boxes[i].x * junction_boxes[j].x
    }
  }
  abort("unimplemented")
}

///|
test "test_part1" {
  let input = try! @fs.read_file_to_string("cmd/day08/input/small.txt")
  let expected = try! @fs.read_file_to_string(
    "cmd/day08/output/small/part1.txt",
  )
  let actual = input |> parse |> part1(connections=10)
  assert_eq(actual.to_string()[:], expected.trim_space())
}

///|
test "test_part2" {
  let input = try! @fs.read_file_to_string("cmd/day08/input/small.txt")
  let expected = try! @fs.read_file_to_string(
    "cmd/day08/output/small/part2.txt",
  )
  let actual = input |> parse |> part2
  assert_eq(actual.to_string()[:], expected.trim_space())
}
