///|
fn main {
  let input = try! @fs.read_file_to_string("cmd/day11/input/large.txt")
  println("Part 1: \{input |> parse |> part1}")
  println("Part 2: \{input |> parse |> part2}")
}

///|
struct Device {
  name : String
  outputs : Array[String]
}

///|
fn parse(input : String) -> Array[Device] {
  input.trim_space().split("\n").map(parse_line).to_array()
}

///|
fn parse_line(line : StringView) -> Device {
  let parts = line.split(": ").to_array()
  let name = parts[0].to_string()
  let outputs = parts[1].split(" ").map(s => s.to_string()).to_array()
  { name, outputs }
}

///|
fn part1(devices : Array[Device]) -> Int {
  let graph = make_graph(devices)
  let ord = topological_sort(graph)
  let paths = @hashmap.HashMap::new()
  paths.set("you", 1)
  for u in ord {
    for v in graph.get(u).unwrap() {
      if paths.get(u) is Some(p_u) {
        let p_v = paths.get_or_default(v, 0)
        paths.set(v, p_v + p_u)
      }
    }
  }
  paths.get("out").unwrap()
}

///|
fn part2(devices : Array[Device]) -> UInt64 {
  let graph = make_graph(devices)
  let ord = topological_sort(graph)
  let paths = @hashmap.HashMap::new()
  paths.set(("svr", State::None), 1UL)
  for u in ord {
    for v in graph.get(u).unwrap() {
      for s in [State::None, State::DAC, State::FFT, State::Both] {
        if paths.get((u, s)) is Some(p_u) {
          let s_v = s.transition(v)
          let p_v = paths.get_or_default((v, s_v), 0)
          paths.set((v, s_v), p_v + p_u)
        }
      }
    }
  }
  paths.get(("out", State::Both)).unwrap()
}

///|
enum State {
  None
  DAC
  FFT
  Both
} derive(Eq, Hash)

///|
fn State::transition(self : State, device_name : String) -> State {
  match device_name {
    "dac" =>
      match self {
        None => DAC
        DAC => DAC
        FFT => Both
        Both => Both
      }
    "fft" =>
      match self {
        None => FFT
        DAC => Both
        FFT => FFT
        Both => Both
      }
    _ => self
  }
}

///|
fn make_graph(
  devices : Array[Device],
) -> @hashmap.HashMap[String, Array[String]] {
  let graph = @hashmap.HashMap::new()
  for d in devices {
    graph.set(d.name, Array::new())
    for o in d.outputs {
      graph.set(o, Array::new())
    }
  }
  for d in devices {
    for o in d.outputs {
      // graph[d.name].push(o) だとなぜかエラーになる
      graph.get(d.name).unwrap().push(o)
    }
  }
  graph
}

///|
fn topological_sort(
  graph : @hashmap.HashMap[String, Array[String]],
) -> Array[String] {
  let in_degree = @hashmap.HashMap::new()
  for _, vs in graph {
    for v in vs {
      let deg = in_degree.get_or_default(v, 0)
      in_degree.set(v, deg + 1)
    }
  }
  let que = @queue.Queue::new()
  for v, _ in graph {
    // degree 0
    if in_degree.contains(v) == false {
      que.push(v)
    }
  }
  let ord = Array::new(capacity=graph.length())
  while que.pop() is Some(u) {
    ord.push(u)
    guard graph.get(u) is Some(vs) else { continue }
    for v in vs {
      // in_degree[v] - 1
      let new_deg = in_degree.get(v).unwrap() - 1
      in_degree.set(v, new_deg)
      if new_deg == 0 {
        que.push(v)
      }
    }
  }
  ord
}

///|
test "test_part1" {
  let input = try! @fs.read_file_to_string("cmd/day11/input/small/part1.txt")
  let expected = try! @fs.read_file_to_string(
    "cmd/day11/output/small/part1.txt",
  )
  let actual = input |> parse |> part1
  assert_eq(actual.to_string()[:], expected.trim_space())
}

///|
test "test_part2" {
  let input = try! @fs.read_file_to_string("cmd/day11/input/small/part2.txt")
  let expected = try! @fs.read_file_to_string(
    "cmd/day11/output/small/part2.txt",
  )
  let actual = input |> parse |> part2
  assert_eq(actual.to_string()[:], expected.trim_space())
}
