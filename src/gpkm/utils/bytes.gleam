import gleam/int
import gleam/list
import gleam/result

pub type Bytes =
  List(Int)

pub type Chunks =
  List(Bytes)

pub type Endian {
  BigEndian
  LittleEndian
}

@external(erlang, "erlang", "binary_to_list")
pub fn bits_to_bytes(bits: BitArray) -> List(Int)

@external(erlang, "erlang", "list_to_binary")
pub fn bytes_to_bits(bytes: List(Int)) -> BitArray

/// Extracts a slice from a bytes list
///
/// ```gleam
/// [0,1,2,3,4,5] |> slice(1, 4)
/// // -> [1,2,3,4]
///
/// [0,1,2,3,4,5] |> slice(2, 2)
/// // -> [2]
/// ```
///
pub fn slice(bs: Bytes, start: Int, end: Int) -> Bytes {
  bs |> list.take(end + 1) |> list.drop(start)
}

/// Makes a single-element slice from a bytes list
/// at a given index
///
/// If the index is out of bounds, an empty bytes list is returned
/// 
/// ```gleam
/// [0,1,2,3,4,5] |> at(2)
/// // -> [2]
///
/// [0,1,2,3,4,5] |> at(42)
/// // -> []
///
/// [] |> at(42)
/// // -> []
/// ```
///
pub fn at(xs: Bytes, index: Int) -> Bytes {
  slice(xs, index, index)
}

fn reorder_slice(xs: Bytes, endian: Endian) -> Bytes {
  case endian {
    BigEndian -> xs
    LittleEndian -> list.reverse(xs)
  }
}

/// Extracts a slice from a bytes list
/// reordering it according to a target endian
///
/// ```gleam
/// [0,1,2,3,4,5] |> ordered_slice(1, 4, BigEndian)
/// // -> [1,2,3,4]
///
/// [0,1,2,3,4,5] |> ordered_slice(1, 4, LittleEndian)
/// // -> [4,3,2,1]
/// ```
///
pub fn ordered_slice(xs: Bytes, start: Int, end: Int, endian: Endian) -> Bytes {
  xs |> slice(start, end) |> reorder_slice(endian)
}

/// Makes sized chunks from a slice of a bytes list,
/// reordering each chunk according to the target endian
///
/// ```gleam
/// [0,1,2,3,4,5,6,7,8,9] |> chunked_slice(1, 8, 2, BigEndian)
/// // -> [[1,2], [3,4], [5,6], [7,8]]
///
/// [0,1,2,3,4,5,6,7,8,9] |> chunked_slice(1, 8, 4, LittleEndian)
/// // -> [[4,3,2,1], [8,7,6,5]]
/// ```
///
pub fn chunked_slice(
  xs: Bytes,
  start: Int,
  end: Int,
  chunk_size: Int,
  endian: Endian,
) -> Chunks {
  xs
  |> slice(start, end)
  |> list.sized_chunk(chunk_size)
  |> list.map(reorder_slice(_, endian))
}

/// Converts a bytes list to a number, by concatenating the bytes
///
/// ```gleam
/// // example when: max_byte_value = 0xff
///
/// [0x42, 0xff] |> int.undigits(0xff + 1)
/// // -> 0x42ff
///
/// [0xde, 0xad, 0xbe, 0xef] |> int.undigits(0xff + 1)
/// // -> 0xdeadbeef
/// ```
///
pub fn to_int(xs: Bytes) -> Int {
  let max_byte_value = 0xff

  xs |> int.undigits(max_byte_value + 1) |> result.unwrap(0)
}

/// Takes the 16 leftmost bits from the 32 rightmost bits of a numbe
///
/// To return the "upper 16 bits" of the rand number (that may be bigger than 32bits)
/// the number should first be cast as a 32bits integer (using a 32bits bitmask)
/// then we can take its first 16 bits (by shifting 16bits to the right)
///
/// ```gleam
/// take_upper_16_bits(0xdeadbeef)
/// // -> 0xdead
///
/// take_upper_16_bits(0xf00d1337deadbeef)
/// // -> 0xdead
///
/// take_upper_16_bits(0b00001111000011110000000000000000)
/// // -> 0b0000111100001111
/// ```
///
/// A very uneffective implementation could also be:
///
/// ```gleam
/// number
/// |> int.to_base2
/// |> string.slice(-32, 16)
/// |> int.base_parse(2)
/// |> result.unwrap(0)
/// ```
///
pub fn take_upper_16_bits(number: Int) -> Int {
  let as_i32 = int.bitwise_and(_, 0xffffffff)
  let get_first_16_bits = int.bitwise_shift_right(_, 16)

  number |> as_i32 |> get_first_16_bits
}

/// Converts a 16 bits int, to an 8 bits int, as a bytes list
///
/// ```gleam
/// 0x0123 |> i16_to_i8_bytes(BigEndian)
/// // -> [0x01, 0x23]
///
/// 0x0123 |> i16_to_i8_bytes(LittleEndian)
/// // -> [0x23, 0x01]
/// ```
///
pub fn i16_to_i8_bytes(i16: Int, endian: Endian) -> Bytes {
  let i8_left = int.bitwise_shift_right(i16, 8)
  let i8_right = int.bitwise_and(i16, 0xff)

  case endian {
    LittleEndian -> [i8_right, i8_left]
    BigEndian -> [i8_left, i8_right]
  }
}

/// Checks if nth bit (from right to left) of a number,
/// is set (!= 0) using bitwise
/// ```gleam
/// let num = 10 // 10 == 0 b 1 0 1 0  // number (as bits)
///              //           ^ ^ ^ ^
///              //           3 2 1 0  // bit_position
///
/// is_bit_set(num, 3)
/// // -> True
/// 
/// is_bit_set(num, 2)
/// // -> False
/// 
/// is_bit_set(num, 1)
/// // -> True
/// ```
///
pub fn is_bit_set(number x: Int, bit_position n: Int) -> Bool {
  let mask = 1 |> int.bitwise_shift_left(n)
  let masked_nth_bit = x |> int.bitwise_and(mask)

  masked_nth_bit != 0
}
