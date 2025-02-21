import gleam/int
import gleam/list
import gleam/result
import utils/bytes.{type Bytes}

pub type Action {
  Encrypt
  Decrypt
}

pub type Blocks {
  Blocks(a: Bytes, b: Bytes, c: Bytes, d: Bytes)
}

pub fn rand(seed: Int) -> Int {
  0x41C64E6D * seed + 0x6073
}

/// Shift personality value (PV, a.k.a: pid)
/// accoring to the following formula:
///
/// ```c
/// shift = ((PV & 0x3E000) >> 0xD) % 24
/// ```
///
pub fn shift_personality_value(pid: Bytes) -> Int {
  bytes.to_int(pid)
  |> int.bitwise_and(0x3E000)
  |> int.bitwise_shift_right(0xD)
  |> int.modulo(24)
  |> result.unwrap(0)
}

fn inverse_shuffle(bs: Blocks, shifted_pv: Int) -> Blocks {
  case bs {
    Blocks(a, b, c, d) ->
      case shifted_pv {
        00 -> Blocks(a, b, c, d)
        01 -> Blocks(a, b, d, c)
        02 -> Blocks(a, c, b, d)
        03 -> Blocks(a, c, d, b)
        04 -> Blocks(a, d, b, c)
        05 -> Blocks(a, d, c, b)
        06 -> Blocks(b, a, c, d)
        07 -> Blocks(b, a, d, c)
        08 -> Blocks(b, c, a, d)
        09 -> Blocks(b, c, d, a)
        10 -> Blocks(b, d, a, c)
        11 -> Blocks(b, d, c, a)
        12 -> Blocks(c, a, b, d)
        13 -> Blocks(c, a, d, b)
        14 -> Blocks(c, b, a, d)
        15 -> Blocks(c, b, d, a)
        16 -> Blocks(c, d, a, b)
        17 -> Blocks(c, d, b, a)
        18 -> Blocks(d, a, b, c)
        19 -> Blocks(d, a, c, b)
        20 -> Blocks(d, b, a, c)
        21 -> Blocks(d, b, c, a)
        22 -> Blocks(d, c, a, b)
        23 -> Blocks(d, c, b, a)
        __ -> bs
      }
  }
}

fn ordered_shuffle(bs: Blocks, shifted_pv: Int) -> Blocks {
  case bs {
    Blocks(a, b, c, d) ->
      case shifted_pv {
        00 -> Blocks(a, b, c, d)
        01 -> Blocks(a, b, d, c)
        02 -> Blocks(a, c, b, d)
        03 -> Blocks(a, d, b, c)
        04 -> Blocks(a, c, d, b)
        05 -> Blocks(a, d, c, b)
        06 -> Blocks(b, a, c, d)
        07 -> Blocks(b, a, d, c)
        08 -> Blocks(c, a, b, d)
        09 -> Blocks(d, a, b, c)
        10 -> Blocks(c, a, d, b)
        11 -> Blocks(d, a, c, b)
        12 -> Blocks(b, c, a, d)
        13 -> Blocks(b, d, a, c)
        14 -> Blocks(c, b, a, d)
        15 -> Blocks(d, b, a, c)
        16 -> Blocks(c, d, a, b)
        17 -> Blocks(d, c, a, b)
        18 -> Blocks(b, c, d, a)
        19 -> Blocks(b, d, c, a)
        20 -> Blocks(c, b, d, a)
        21 -> Blocks(d, b, c, a)
        22 -> Blocks(c, d, b, a)
        23 -> Blocks(d, c, b, a)
        __ -> bs
      }
  }
}

fn shuffle_blocks(bs: Blocks, pid: Bytes, ord: Action) -> Blocks {
  let shifted_pv = shift_personality_value(pid)

  let shuffle_function = case ord {
    Encrypt -> ordered_shuffle
    Decrypt -> inverse_shuffle
  }

  shuffle_function(bs, shifted_pv)
}

/// Shuffle blocks according to the specifies rules:
/// https://projectpokemon.org/home/docs/gen-4/pkm-structure-r65/
///
pub fn shuffle_block_bytes(bs: Bytes, pid: Bytes, ord: Action) -> Bytes {
  bs
  |> bytes_as_blocks
  |> shuffle_blocks(pid, ord)
  |> blocks_as_bytes
}

/// Construct Blocks record from block bytes
/// each block is 32 bytes long
///
pub fn bytes_as_blocks(bs: Bytes) -> Blocks {
  let padding = 32

  Blocks(
    a: bytes.slice(bs, 0 * padding, 1 * padding - 1),
    b: bytes.slice(bs, 1 * padding, 2 * padding - 1),
    c: bytes.slice(bs, 2 * padding, 3 * padding - 1),
    d: bytes.slice(bs, 3 * padding, 4 * padding - 1),
  )
}

pub fn blocks_as_bytes(bs: Blocks) -> Bytes {
  list.flatten([bs.a, bs.b, bs.c, bs.d])
}
