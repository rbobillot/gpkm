import gleam/dict
import gleam/int
import gleam/list
import gleam/result
import gleam/string
import pkm/lookup_tables/game_chars
import pkm/lookup_tables/lookup
import pkm/lookup_tables/pokemon_info
import utils/bytes.{type Bytes}

pub type Encoding {
  Bin
  B64
}

pub type EncryptedDataType {
  PkmBits(Encoding)
  SavBits(Encoding)
  SavPkmBits(Encoding)
  PkmFile(Encoding)
  SavFile(Encoding)
  SavPkmFile(Encoding)
}

pub type IndividualValues {
  IndividualValues(hp: Int, atk: Int, def: Int, spe: Int, spa: Int, spd: Int)
}

pub type EffortValues {
  EffortValues(hp: Int, atk: Int, def: Int, spe: Int, spa: Int, spd: Int)
}

pub type Move {
  Move(name: String, pp: Int)
}

pub type Moves {
  Moves(
    move_1: Result(Move, Nil),
    move_2: Result(Move, Nil),
    move_3: Result(Move, Nil),
    move_4: Result(Move, Nil),
  )
}

pub type HiddenPower {
  HiddenPower(power_type: String, base_power: Int)
}

pub type UnencryptedHeaderBytes {
  UnencryptedHeaderBytes(pid: Bytes, tmp: Bytes, checksum: Bytes)
}

pub type UnencryptedPkmBytes {
  UnencryptedPkmBytes(
    //
    // unencrypted header bytes
    //
    pid: Bytes,
    tmp: Bytes,
    checksum: Bytes,
    //
    // Block A ////////////////
    //
    national_pokedex_id: Bytes,
    held_item: Bytes,
    ot_id: Bytes,
    ot_secret_id: Bytes,
    experience_points: Bytes,
    friendship: Bytes,
    ability: Bytes,
    markings: Bytes,
    original_language: Bytes,
    hp_effort_value: Bytes,
    attack_effort_value: Bytes,
    defense_effort_value: Bytes,
    speed_effort_value: Bytes,
    sp_attack_effort_value: Bytes,
    sp_defense_effort_value: Bytes,
    cool_contest_value: Bytes,
    beauty_contest_value: Bytes,
    cute_contest_value: Bytes,
    smart_contest_value: Bytes,
    tough_contest_value: Bytes,
    sheen_contest_value: Bytes,
    sinnoh_ribbon_set_1: Bytes,
    sinnoh_ribbon_set_2: Bytes,
    //
    // Block B ////////////////
    //
    move_1_id: Bytes,
    move_2_id: Bytes,
    move_3_id: Bytes,
    move_4_id: Bytes,
    move_1_current_pp: Bytes,
    move_2_current_pp: Bytes,
    move_3_current_pp: Bytes,
    move_4_current_pp: Bytes,
    move_pp_ups: Bytes,
    // Bits 0-29 - Individual Values
    //
    // Each IV is stored on 5 bits (00000 == 0, 11111 == 31)
    // Each IV is left shifted, so it can be stored on a 32bits Int
    // 00 00000 00000 00000 00000 00000 00000
    //     SPE   SPA   SPE   DEF   ATK   HP
    //
    // Bits [0-4]   - HP ( [0-31] << 0 )
    // Bits [5-9]   - Attack ( [0-31] << 5 )
    // Bits [10-14] - Defense ( [0-31] << 10 )
    // Bits [15-19] - Speed ( [0-31] << 15 )
    // Bits [20-24] - SP Attack ( [0-31] << 20 )
    // Bits [25-29] - SP Defense ( [0-31] << 25 )
    // 
    // Bit 30       - IsEgg Flag
    // Bit 31       - IsNicknamed Flag
    individual_values: Bytes,
    hoenn_ribbon_set_1: Bytes,
    hoenn_ribbon_set_2: Bytes,
    // Encounter Info
    //   Bit 0 - Fateful Encounter Flag
    //   Bit 1 - Female
    //   Bit 2 - Genderless
    //   Bit 3-7 - Alternate Forms
    encounter_main_info: Bytes,
    // Bits 0–4 - Leaves A–E (bit 0 is leftmost)
    // Bit 5 - Leaf Crown
    hgss_shiny_leaves: Bytes,
    unused_b_1: Bytes,
    egg_platinum_location: Bytes,
    met_at_platinum_location: Bytes,
    //
    // Block C ////////////////
    //
    nickname: Bytes,
    unused_c_1: Bytes,
    origin_game: Bytes,
    sinnoh_ribbon_set_3: Bytes,
    sinnoh_ribbon_set_4: Bytes,
    unused_c_2: Bytes,
    //
    // Block D ////////////////
    //
    ot_name: Bytes,
    date_egg_received: Bytes,
    date_met: Bytes,
    egg_diamond_pearl_location: Bytes,
    met_at_diamond_pearl_location: Bytes,
    pokerus: Bytes,
    poke_ball: Bytes,
    // bit 0-6 - met at level
    // bit 7 - female ot gender
    encounter_bonus_info: Bytes,
    encounter_type: Bytes,
    hgss_poke_ball: Bytes,
    unused_d_1: Bytes,
    //
    // Battle Stats ////////////////
    //
    // Pokemon's current status
    //   Bits 0-2 - Asleep (0-7 rounds)
    //   Bit 3 - Poisoned
    //   Bit 4 - Burned
    //   Bit 5 - Frozen
    //   Bit 6 - Paralyzed
    //   Bit 7 - Toxic
    current_status: Bytes,
    // Flags - Max Value 0xF0
    unknown_1: Bytes,
    unknown_2: Bytes,
    level: Bytes,
    seals_capsule_index: Bytes,
    current_hp: Bytes,
    max_hp: Bytes,
    attack: Bytes,
    defense: Bytes,
    speed: Bytes,
    special_attack: Bytes,
    special_defense: Bytes,
    // Contains Trash Data
    unknown_3: Bytes,
    seal_coordinates: Bytes,
    b64_pkm: String,
  )
}

/// As the in-game names are composed by non-standard unicode chars
/// they need to be deserialized using a lookup table
///
/// In-game names (or nicknames), are little endian bytes lists with variable lengths.
///
/// Each encoded letter is a little endian 16bits (2 bytes) value,
/// used as an index of the corresponding unicode letter, from the lookup table
///
/// When the name's length is smaller than the its reserved offset length,
/// an EOL byte (0xffff) is used to determine the end of a name.
///
/// ```
/// Example:
/// - field:   Origin Trainer Name
/// - offset:  0x68-0x77 (length: 15)
/// - OT name: "John" (length: 4)
/// - bytes:   [ 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0xff, 0xff, 'n', 'h', 'o', 'J' ]
///                                                         ^    ^    ^    ^
///                          each letter here is used to visualize the logic but
///                          is actually a 2-bytes value (the index of the letter)
/// ```
///
pub fn get_name(data: Bytes) -> String {
  let empty = 0x00
  let end_of_line = 0xff

  let unicode_chars_lookup_table =
    list.range(0, list.length(game_chars.unicode_chars))
    |> list.zip(game_chars.unicode_chars)
    |> dict.from_list

  let encoded_name_bytes =
    data
    |> list.drop_while(fn(b) { b == empty || b == end_of_line })
    |> list.window(2)
    |> list.map(bytes.to_int)

  let decoded_name_bytes =
    encoded_name_bytes
    |> list.filter_map(fn(i) { dict.get(unicode_chars_lookup_table, i - 1) })

  decoded_name_bytes
  |> list.filter_map(string.utf_codepoint)
  |> string.from_utf_codepoints
  |> string.reverse
}

/// Each EV is a single-byte value
///
pub fn get_evs(pkm_bytes: UnencryptedPkmBytes) -> EffortValues {
  EffortValues(
    hp: bytes.to_int(pkm_bytes.hp_effort_value),
    atk: bytes.to_int(pkm_bytes.attack_effort_value),
    def: bytes.to_int(pkm_bytes.defense_effort_value),
    spe: bytes.to_int(pkm_bytes.speed_effort_value),
    spa: bytes.to_int(pkm_bytes.sp_attack_effort_value),
    spd: bytes.to_int(pkm_bytes.defense_effort_value),
  )
}

/// Use IV max value: `0x1f` (a.k.a `31`), as bit mask to extract target IV
///
/// ```c
/// IVS >> BY & MASK
/// ```
///
pub fn get_shifted_iv(ivs: Int, by: Int) -> Int {
  let iv_max_value_mask = 0x1f

  ivs
  |> int.bitwise_shift_right(by)
  |> int.bitwise_and(iv_max_value_mask)
}

/// Extract each IV from a 32bits (4 bytes) Int
/// More info in the UnencryptedPkmBytes type definition
///
/// The 32bits Int also hold 2 flags (isEgg, isNicknamed),
/// but I don't use them for now (maybe later, to make a more exhaustive JSON)
///
pub fn get_ivs(data: Bytes) -> IndividualValues {
  let ivs = bytes.to_int(data)

  IndividualValues(
    hp: get_shifted_iv(ivs, 0),
    atk: get_shifted_iv(ivs, 5),
    def: get_shifted_iv(ivs, 10),
    spe: get_shifted_iv(ivs, 15),
    spa: get_shifted_iv(ivs, 20),
    spd: get_shifted_iv(ivs, 25),
  )
}

/// Get move names from the 'moves' lookup table
///
pub fn lookup_move(move_id: Bytes, move_pp: Bytes) -> Result(Move, Nil) {
  move_id
  |> lookup.lookup_ingame_str(pokemon_info.moves)
  |> result.map(fn(name) { Move(name, bytes.to_int(move_pp)) })
}

/// Get moves and their pps
/// Each move/pp combo will be a Result(Move, Nil),
/// as a Pokemon might not always have learned 4 moves
///
pub fn get_moves(upbs: UnencryptedPkmBytes) -> Moves {
  Moves(
    move_1: lookup_move(upbs.move_1_id, upbs.move_1_current_pp),
    move_2: lookup_move(upbs.move_2_id, upbs.move_2_current_pp),
    move_3: lookup_move(upbs.move_3_id, upbs.move_3_current_pp),
    move_4: lookup_move(upbs.move_4_id, upbs.move_4_current_pp),
    // move_pp_ups: Bytes,
  )
}
