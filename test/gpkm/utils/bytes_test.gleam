import gleeunit/should
import gpkm/utils/bytes

const empty_bytes = []

const five_bytes = [0, 1, 2, 3, 4, 5]

const nine_bytes = [0, 1, 2, 3, 4, 5, 6, 7, 8, 9]

pub fn at_test() {
  empty_bytes
  |> bytes.at(5)
  |> should.equal([])

  five_bytes
  |> bytes.at(5)
  |> should.equal([5])
}

pub fn slice_test() {
  empty_bytes
  |> bytes.slice(1, 4)
  |> should.equal([])

  five_bytes
  |> bytes.slice(1, 4)
  |> should.equal([1, 2, 3, 4])
}

pub fn ordered_slice_test() {
  empty_bytes
  |> bytes.ordered_slice(1, 4, bytes.BigEndian)
  |> should.equal([])

  five_bytes
  |> bytes.ordered_slice(1, 4, bytes.BigEndian)
  |> should.equal([1, 2, 3, 4])

  five_bytes
  |> bytes.ordered_slice(1, 4, bytes.LittleEndian)
  |> should.equal([4, 3, 2, 1])
}

pub fn chunked_slice_test() {
  nine_bytes
  |> bytes.chunked_slice(1, 8, 2, bytes.BigEndian)
  |> should.equal([[1, 2], [3, 4], [5, 6], [7, 8]])

  nine_bytes
  |> bytes.chunked_slice(1, 8, 4, bytes.LittleEndian)
  |> should.equal([[4, 3, 2, 1], [8, 7, 6, 5]])
}

pub fn to_int_test() {
  bytes.to_int([0x42, 0xff])
  |> should.equal(0x42ff)

  bytes.to_int([0xde, 0xad, 0xbe, 0xef])
  |> should.equal(0xdeadbeef)
}

pub fn take_upper_16_bits_test() {
  let i64 = 0xf00d1337deadbeef
  let i32 = 0xdeadbeef
  let i16_upper = 0xdead

  i32
  |> bytes.take_upper_16_bits
  |> should.equal(i16_upper)

  // should take upper 16 bits from the rightmost 32 bits
  i64
  |> bytes.take_upper_16_bits
  |> should.equal(i16_upper)
}

pub fn i16_to_i8_bytes() {
  0x0123
  |> bytes.i16_to_i8_bytes(bytes.BigEndian)
  |> should.equal([0x01, 0x23])

  0x0123
  |> bytes.i16_to_i8_bytes(bytes.LittleEndian)
  |> should.equal([0x23, 0x01])
}

pub fn is_bit_set_test() {
  let num = 10

  bytes.is_bit_set(num, 0)
  |> should.be_false

  bytes.is_bit_set(num, 1)
  |> should.be_true

  bytes.is_bit_set(num, 2)
  |> should.be_false

  bytes.is_bit_set(num, 3)
  |> should.be_true
}
