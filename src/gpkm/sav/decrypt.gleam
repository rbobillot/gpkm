import gleam/int
import gleam/list
import gpkm/pkm/ser_de
import gpkm/sav/blocks
import gpkm/utils/bytes.{type Bytes, type Chunks}

fn tr_unencrypt_chunks(
  bytes_chunks: Chunks,
  rand_value: Int,
  res: Bytes,
) -> Bytes {
  case bytes_chunks {
    [] -> res |> list.reverse
    [chunk, ..t] -> {
      let next_rand = blocks.rand(rand_value)
      let rand_i16 = bytes.take_upper_16_bits(rand_value)
      let chunk_i16 = bytes.to_int(chunk)
      let unencrypted_byte = int.bitwise_exclusive_or(chunk_i16, rand_i16)

      tr_unencrypt_chunks(t, next_rand, [unencrypted_byte, ..res])
    }
  }
}

fn unencrypt_chunks_as_bytes(bytes_chunks: Chunks, rand_seed: Bytes) -> Bytes {
  let initial_rand_value = rand_seed |> bytes.to_int |> blocks.rand

  tr_unencrypt_chunks(bytes_chunks, initial_rand_value, [])
  |> list.flat_map(bytes.i16_to_i8_bytes(_, bytes.LittleEndian))
}

/// Decrypt pkm data when it is encrypted using .sav format.
/// According to
/// [ProjectPokemon documentation](https://projectpokemon.org/home/docs/gen-4/pkm-structure-r65/)
///
pub fn decrypt_pkm(pkm_bits: BitArray) -> Bytes {
  let pkm_bytes = bytes.bits_to_bytes(pkm_bits)
  let header = ser_de.get_unencrypted_header(pkm_bytes, bytes.LittleEndian)

  let decrypted_block_bytes =
    pkm_bytes
    |> bytes.chunked_slice(0x08, 0x87, 2, bytes.LittleEndian)
    |> unencrypt_chunks_as_bytes(header.checksum)
    |> blocks.shuffle_block_bytes(header.pid, blocks.Decrypt)

  let decrypted_non_block_bytes =
    pkm_bytes
    |> bytes.chunked_slice(0x88, 0xeb, 2, bytes.LittleEndian)
    |> unencrypt_chunks_as_bytes(header.pid)

  let decrypted_pkm =
    header
    |> ser_de.header_as_bytes
    |> list.append(decrypted_block_bytes)
    |> list.append(decrypted_non_block_bytes)

  decrypted_pkm
}
