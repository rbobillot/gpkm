import gleam/list
import gleeunit/should
import sav/blocks

const pid_shift_00 = [0x00, 0x00, 0x00, 0x00]

const pid_shift_01 = [0x42, 0xff, 0x21, 0xff]

const pid_shift_16 = [0x00, 0x42, 0x00, 0x21]

pub fn shuffle_block_bytes_test() {
  let block_a = list.repeat(0, 32)
  let block_b = list.repeat(1, 32)
  let block_c = list.repeat(2, 32)
  let block_d = list.repeat(3, 32)

  let block_bytes =
    block_a
    |> list.append(block_b)
    |> list.append(block_c)
    |> list.append(block_d)

  let abcd_shuffle =
    blocks.Blocks(block_a, block_b, block_c, block_d)
    |> blocks.blocks_as_bytes

  let abdc_shuffle =
    blocks.Blocks(block_a, block_b, block_d, block_c)
    |> blocks.blocks_as_bytes

  let cdab_shuffle =
    blocks.Blocks(block_c, block_d, block_a, block_b)
    |> blocks.blocks_as_bytes

  blocks.shuffle_block_bytes(block_bytes, pid_shift_00, blocks.Decrypt)
  |> should.equal(abcd_shuffle)

  blocks.shuffle_block_bytes(block_bytes, pid_shift_01, blocks.Decrypt)
  |> should.equal(abdc_shuffle)

  blocks.shuffle_block_bytes(block_bytes, pid_shift_16, blocks.Decrypt)
  |> should.equal(cdab_shuffle)
}

pub fn shift_personality_value_test() {
  blocks.shift_personality_value(pid_shift_00)
  |> should.equal(0)

  blocks.shift_personality_value(pid_shift_01)
  |> should.equal(1)

  blocks.shift_personality_value(pid_shift_16)
  |> should.equal(16)
}

pub fn bytes_as_blocks_test() {
  let block_a = list.repeat(0, 32)
  let block_b = list.repeat(1, 32)
  let block_c = list.repeat(2, 32)
  let block_d = list.repeat(3, 32)

  let block_bytes =
    block_a
    |> list.append(block_b)
    |> list.append(block_c)
    |> list.append(block_d)

  blocks.bytes_as_blocks(block_bytes)
  |> should.equal(blocks.Blocks(block_a, block_b, block_c, block_d))
}

pub fn blocks_as_bytes_test() {
  let block_a = list.repeat(0, 32)
  let block_b = list.repeat(1, 32)
  let block_c = list.repeat(2, 32)
  let block_d = list.repeat(3, 32)

  let blocks = blocks.Blocks(block_a, block_b, block_c, block_d)

  let block_bytes =
    block_a
    |> list.append(block_b)
    |> list.append(block_c)
    |> list.append(block_d)

  blocks
  |> blocks.blocks_as_bytes
  |> should.equal(block_bytes)
}
