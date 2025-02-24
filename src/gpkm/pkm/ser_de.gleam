import gleam/bit_array
import gleam/list
import gleam/result
import gleam/string
import gpkm/pkm/pkm_builder.{type Pkm} as pkm
import gpkm/pkm/pkm_bytes.{type EncryptedDataType, B64, Bin, PkmBits, PkmFile}
import gpkm/utils/bytes.{type Bytes}
import gpkm/utils/files

pub type Errors {
  InvalidSize(dt: EncryptedDataType)
  ReadError(dt: EncryptedDataType)
  UnhandledDataType(dt: EncryptedDataType)
}

const min_pkm_size = 136

const max_pkm_size = 236

pub fn header_as_bytes(h: pkm_bytes.UnencryptedHeaderBytes) -> Bytes {
  list.flat_map([h.pid, h.tmp, h.checksum], list.reverse)
}

pub fn get_unencrypted_header(
  pkm_bytes: Bytes,
  endian: bytes.Endian,
) -> pkm_bytes.UnencryptedHeaderBytes {
  pkm_bytes.UnencryptedHeaderBytes(
    pid: bytes.ordered_slice(pkm_bytes, 0x00, 0x03, endian),
    tmp: bytes.ordered_slice(pkm_bytes, 0x04, 0x05, endian),
    checksum: bytes.ordered_slice(pkm_bytes, 0x06, 0x07, endian),
  )
}

/// Construct UnencryptedPkmBytes record, storing named pkm data bytes,
/// according to ProjectPokemon documentation:
///
/// https://projectpokemon.org/home/docs/gen-4/pkm-structure-r65/
///
/// Handling Gen4 PKM structure for now,
/// but newer generations should be handled later
///
pub fn get_unencrypted_pkm_bytes(
  pkm_bits: BitArray,
  endian: bytes.Endian,
) -> pkm_bytes.UnencryptedPkmBytes {
  let bs = bytes.bits_to_bytes(pkm_bits)

  pkm_bytes.UnencryptedPkmBytes(
    pid: bytes.ordered_slice(bs, 0x00, 0x03, endian),
    tmp: bytes.ordered_slice(bs, 0x04, 0x05, endian),
    checksum: bytes.ordered_slice(bs, 0x06, 0x07, endian),
    national_pokedex_id: bytes.ordered_slice(bs, 0x08, 0x09, endian),
    held_item: bytes.ordered_slice(bs, 0x0a, 0x0b, endian),
    ot_id: bytes.ordered_slice(bs, 0x0c, 0x0d, endian),
    ot_secret_id: bytes.ordered_slice(bs, 0x0e, 0x0f, endian),
    experience_points: bytes.ordered_slice(bs, 0x10, 0x13, endian),
    friendship: bytes.at(bs, 0x14),
    ability: bytes.at(bs, 0x15),
    markings: bytes.at(bs, 0x16),
    original_language: bytes.at(bs, 0x17),
    hp_effort_value: bytes.at(bs, 0x18),
    attack_effort_value: bytes.at(bs, 0x19),
    defense_effort_value: bytes.at(bs, 0x1a),
    speed_effort_value: bytes.at(bs, 0x1b),
    sp_attack_effort_value: bytes.at(bs, 0x1c),
    sp_defense_effort_value: bytes.at(bs, 0x1d),
    cool_contest_value: bytes.at(bs, 0x1e),
    beauty_contest_value: bytes.at(bs, 0x1f),
    cute_contest_value: bytes.at(bs, 0x20),
    smart_contest_value: bytes.at(bs, 0x21),
    tough_contest_value: bytes.at(bs, 0x22),
    sheen_contest_value: bytes.at(bs, 0x23),
    sinnoh_ribbon_set_1: bytes.ordered_slice(bs, 0x24, 0x25, endian),
    sinnoh_ribbon_set_2: bytes.ordered_slice(bs, 0x26, 0x27, endian),
    move_1_id: bytes.ordered_slice(bs, 0x28, 0x29, endian),
    move_2_id: bytes.ordered_slice(bs, 0x2a, 0x2b, endian),
    move_3_id: bytes.ordered_slice(bs, 0x2c, 0x2d, endian),
    move_4_id: bytes.ordered_slice(bs, 0x2e, 0x2f, endian),
    move_1_current_pp: bytes.at(bs, 0x30),
    move_2_current_pp: bytes.at(bs, 0x31),
    move_3_current_pp: bytes.at(bs, 0x32),
    move_4_current_pp: bytes.at(bs, 0x33),
    move_pp_ups: bytes.ordered_slice(bs, 0x34, 0x37, endian),
    individual_values: bytes.ordered_slice(bs, 0x38, 0x3b, endian),
    hoenn_ribbon_set_1: bytes.ordered_slice(bs, 0x3c, 0x3d, endian),
    hoenn_ribbon_set_2: bytes.ordered_slice(bs, 0x3e, 0x3f, endian),
    encounter_main_info: bytes.at(bs, 0x40),
    hgss_shiny_leaves: bytes.at(bs, 0x41),
    unused_b_1: bytes.ordered_slice(bs, 0x42, 0x43, endian),
    egg_platinum_location: bytes.ordered_slice(bs, 0x44, 0x45, endian),
    met_at_platinum_location: bytes.ordered_slice(bs, 0x46, 0x47, endian),
    nickname: bytes.ordered_slice(bs, 0x48, 0x5d, endian),
    unused_c_1: bytes.at(bs, 0x5e),
    origin_game: bytes.at(bs, 0x5f),
    sinnoh_ribbon_set_3: bytes.ordered_slice(bs, 0x60, 0x61, endian),
    sinnoh_ribbon_set_4: bytes.ordered_slice(bs, 0x62, 0x63, endian),
    unused_c_2: bytes.ordered_slice(bs, 0x64, 0x67, endian),
    ot_name: bytes.ordered_slice(bs, 0x68, 0x77, endian),
    date_egg_received: bytes.ordered_slice(bs, 0x78, 0x7a, endian),
    date_met: bytes.ordered_slice(bs, 0x7b, 0x7d, endian),
    egg_diamond_pearl_location: bytes.ordered_slice(bs, 0x7e, 0x7f, endian),
    met_at_diamond_pearl_location: bytes.ordered_slice(bs, 0x80, 0x81, endian),
    pokerus: bytes.at(bs, 0x82),
    poke_ball: bytes.at(bs, 0x83),
    encounter_bonus_info: bytes.at(bs, 0x84),
    encounter_type: bytes.at(bs, 0x85),
    hgss_poke_ball: bytes.at(bs, 0x86),
    unused_d_1: bytes.at(bs, 0x87),
    current_status: bytes.at(bs, 0x88),
    unknown_1: bytes.at(bs, 0x89),
    unknown_2: bytes.ordered_slice(bs, 0x8a, 0x8b, endian),
    level: bytes.at(bs, 0x8c),
    seals_capsule_index: bytes.at(bs, 0x8d),
    current_hp: bytes.ordered_slice(bs, 0x8e, 0x8f, endian),
    max_hp: bytes.ordered_slice(bs, 0x90, 0x91, endian),
    attack: bytes.ordered_slice(bs, 0x92, 0x93, endian),
    defense: bytes.ordered_slice(bs, 0x94, 0x95, endian),
    speed: bytes.ordered_slice(bs, 0x96, 0x97, endian),
    special_attack: bytes.ordered_slice(bs, 0x98, 0x99, endian),
    special_defense: bytes.ordered_slice(bs, 0x9a, 0x9b, endian),
    unknown_3: bytes.ordered_slice(bs, 0x9c, 0xd3, endian),
    seal_coordinates: bytes.ordered_slice(bs, 0xd4, 0xeb, endian),
    b64_pkm: bs |> bytes.bytes_to_bits |> bit_array.base64_encode(True),
  )
}

/// Construct Pkm record,
/// by selecting, then converting pkm_bytes fields
///
/// This Pkm record will be serialized to JSON
///
pub fn build_pkm_from_bytes(pbs: pkm_bytes.UnencryptedPkmBytes) -> Pkm {
  pkm.new(pbs.b64_pkm)
  |> pkm.with_pid(pbs.pid)
  |> pkm.with_nickname(pbs.nickname)
  |> pkm.with_species(pbs.national_pokedex_id)
  |> pkm.with_national_pokedex_id(pbs.national_pokedex_id)
  |> pkm.with_held_item(pbs.held_item)
  |> pkm.with_origin_game(pbs.origin_game)
  |> pkm.with_ot_id(pbs.ot_id)
  |> pkm.with_ot_secret_id(pbs.ot_secret_id)
  |> pkm.with_experience_points(pbs.experience_points)
  |> pkm.with_friendship(pbs.friendship)
  |> pkm.with_ability(pbs.ability)
  |> pkm.with_original_language(pbs.original_language)
  |> pkm.with_effort_values(pbs)
  |> pkm.with_moves(pbs)
  |> pkm.with_individual_values(pbs.individual_values)
  |> pkm.with_ot_name(pbs.ot_name)
  |> pkm.with_shiny(pbs.pid, pbs.ot_id, pbs.ot_secret_id)
  |> pkm.with_level(pbs.level)
  |> pkm.with_nature(pbs.pid)
  |> pkm.with_gender(pbs.encounter_main_info)
  |> pkm.with_hidden_power()
}

pub fn get_current_pkm_bytes_size(
  bits_read: Result(BitArray, Nil),
) -> Result(Int, Nil) {
  case bits_read |> result.map(bit_array.byte_size) {
    Ok(len) if len >= max_pkm_size -> Ok(max_pkm_size)
    Ok(len) if len >= min_pkm_size -> Ok(min_pkm_size)
    _ -> Error(Nil)
  }
}

/// Deserialize base64 string, no matter its format:
/// - single line
/// - multiple spaced lines
///
pub fn deserialize_b64(b64: String) -> Result(BitArray, Nil) {
  b64
  |> string.split("\n")
  |> list.map(string.trim)
  |> string.join("")
  |> bit_array.base64_decode
}

/// Converts BitArray's encoding to Bin:
/// - if the BitArray's content is already Bin, it remains unchained
/// - else, it decodes the B64 BitArray
///
pub fn as_binary(
  bits_read: Result(BitArray, Nil),
  data_type: EncryptedDataType,
) -> Result(BitArray, Nil) {
  case bits_read, data_type {
    Ok(____), PkmFile(Bin) | Ok(____), PkmBits(Bin) -> bits_read
    Ok(bits), PkmFile(B64) | Ok(bits), PkmBits(B64) ->
      bits
      |> bit_array.to_string
      |> result.then(deserialize_b64)
    _, _ -> Error(Nil)
  }
}

/// Sanitize read data by limiting its size
/// - 236 if pkm size >= 236
/// - 136 if pkm size >= 136
///
pub fn slice_bits(
  bits_read: Result(BitArray, Nil),
  dt: EncryptedDataType,
) -> Result(BitArray, Errors) {
  case bits_read, get_current_pkm_bytes_size(bits_read) {
    Ok(bs), Ok(size) ->
      bit_array.slice(bs, 0, size)
      |> result.map_error(fn(_) { InvalidSize(dt) })
    Error(_), _ -> Error(ReadError(dt))
    _, Error(_) -> Error(InvalidSize(dt))
  }
}

/// Read and deserialize PKM data depending on data type
/// ```gleam
///  read_pkm(pkm_path, PkmFile(Bin))
///  // read simple .pkm file (where content is binary data)
///
///  read_pkm(pkm_path, PkmFile(B64))
///  // read base64 .pkm file (where content is a base64 pkm string)
///
///  read_pkm(pkm_bitarray, PkmBits(Bin))
///  // read pkm bitarray
///
///  read_pkm(pkm_b64_str, PkmBits(B64))
///  // read base64 pkm string (convert it to binary data)
/// ```
///
pub fn read_pkm(pkm_data: String, dt: EncryptedDataType) -> Result(Pkm, Errors) {
  let pkm_bitarray = case pkm_data, dt {
    b64, PkmBits(B64) -> slice_bits(b64 |> deserialize_b64, PkmFile(B64))
    pth, PkmFile(___) -> slice_bits(pth |> files.read_file |> as_binary(dt), dt)
    _, dt -> Error(UnhandledDataType(dt))
  }

  pkm_bitarray
  |> result.map(get_unencrypted_pkm_bytes(_, bytes.LittleEndian))
  |> result.map(build_pkm_from_bytes)
}
