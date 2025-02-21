import gleam/bit_array
import gleam/result

@external(erlang, "file", "read_file")
pub fn read_file(path: String) -> Result(BitArray, err)

pub fn read_file_as_str(path: String) -> Result(String, Nil) {
  path
  |> read_file
  |> result.then(bit_array.to_string)
}

@external(erlang, "file", "write_file")
pub fn write_file(path: String, bytes: BitArray) -> Result(Nil, err)
