import gleam/dict
import gleam/int
import gleam/list
import gleam/option.{type Option, None, Some}
import gpkm/pkm/lookup_tables/game_info
import gpkm/pkm/lookup_tables/lookup
import gpkm/pkm/lookup_tables/pokemon_info
import gpkm/pkm/pkm_bytes.{
  type EffortValues, type HiddenPower, type IndividualValues, type Moves,
}
import gpkm/utils/bytes.{type Bytes}

/// Pkm record, containing the most valuable info about a Pokemon:
/// pid, nickname, species, moves, ivs, evs, ot id/sid, shininess...
///
/// It also contains the original pkm bytes as a base64 string
///
/// Each Pkm parameter is an Option,
/// to construct the record using the builder pattern
///
/// ```gleam
/// let b64_pkm_data = ""
/// let pid_bytes = [42, 21, 12, 24]
/// let level_bytes = [42]
///
/// pkm_builder.new(b64_pkm_data)
/// |> with_pid(pid_bytes)
/// |> with_level(level_bytes)
/// // -> Pkm(pid: Some(42211224), level: 42, nickname: None, ..., b64_pkm_data: "")
/// ```
///
pub type Pkm {
  Pkm(
    pid: Option(Int),
    nickname: Option(String),
    national_pokedex_id: Option(Int),
    held_item: Option(String),
    origin_game: Option(String),
    ot_name: Option(String),
    ot_id: Option(Int),
    ot_secret_id: Option(Int),
    moves: Option(Moves),
    ability: Option(String),
    individual_values: Option(IndividualValues),
    effort_values: Option(EffortValues),
    experience_points: Option(Int),
    friendship: Option(Int),
    original_language: Option(String),
    shiny: Option(Bool),
    level: Option(Int),
    nature: Option(String),
    species: Option(String),
    gender: Option(String),
    hidden_power: Option(HiddenPower),
    b64_pkm_data: String,
  )
}

/// Construct the Pkm using the builder pattern,
/// with a mandatory pattern: the pkm data as a base64 string,
/// which will be used to serialize the Pkm as pkm binary
///
pub fn new(b64_pkm_data: String) -> Pkm {
  Pkm(
    pid: None,
    nickname: None,
    national_pokedex_id: None,
    held_item: None,
    origin_game: None,
    ot_name: None,
    ot_id: None,
    ot_secret_id: None,
    moves: None,
    ability: None,
    individual_values: None,
    effort_values: None,
    experience_points: None,
    friendship: None,
    original_language: None,
    shiny: None,
    level: None,
    nature: None,
    species: None,
    gender: None,
    hidden_power: None,
    b64_pkm_data: b64_pkm_data,
  )
}

pub fn with_pid(pkm: Pkm, pid: Bytes) -> Pkm {
  Pkm(..pkm, pid: Some(bytes.to_int(pid)))
}

pub fn with_nickname(pkm: Pkm, nickname: Bytes) -> Pkm {
  Pkm(..pkm, nickname: Some(pkm_bytes.get_name(nickname)))
}

pub fn with_national_pokedex_id(pkm: Pkm, national_pokedex_id: Bytes) -> Pkm {
  Pkm(..pkm, national_pokedex_id: Some(bytes.to_int(national_pokedex_id)))
}

pub fn with_held_item(pkm: Pkm, held_item: Bytes) -> Pkm {
  Pkm(
    ..pkm,
    held_item: option.from_result(lookup.lookup_ingame_str(
      held_item,
      pokemon_info.held_items,
    )),
  )
}

fn get_origin_game(origin_game: Int) -> Option(String) {
  game_info.game
  |> dict.from_list
  |> dict.get(origin_game)
  |> option.from_result
}

/// This Pkm `origin_game` parameter,
/// needs to be set before the `shiny` parameter.
///
/// The origin_game will be used to determine shininess,
/// as shiny odds have been increased since Gen6
///
pub fn with_origin_game(pkm: Pkm, origin_game: Bytes) -> Pkm {
  Pkm(..pkm, origin_game: get_origin_game(bytes.to_int(origin_game)))
}

pub fn with_ot_name(pkm: Pkm, ot_name: Bytes) -> Pkm {
  Pkm(..pkm, ot_name: Some(pkm_bytes.get_name(ot_name)))
}

pub fn with_ot_id(pkm: Pkm, ot_id: Bytes) -> Pkm {
  Pkm(..pkm, ot_id: Some(bytes.to_int(ot_id)))
}

pub fn with_ot_secret_id(pkm: Pkm, ot_secret_id: Bytes) -> Pkm {
  Pkm(..pkm, ot_secret_id: Some(bytes.to_int(ot_secret_id)))
}

/// Uses the whole UnencryptedPkmBytes to build Pkm with `moves`
///
/// As each move/pp is a field of UnencryptedPkmBytes,
/// each move/pp will be extracted from the `get_moves` function
///
pub fn with_moves(pkm: Pkm, bs: pkm_bytes.UnencryptedPkmBytes) -> Pkm {
  Pkm(..pkm, moves: Some(pkm_bytes.get_moves(bs)))
}

/// Gets the ability from the corresponding lookup table
///
pub fn with_ability(pkm: Pkm, ability: Bytes) -> Pkm {
  Pkm(
    ..pkm,
    ability: lookup.lookup_ingame_str(ability, pokemon_info.abilities)
      |> option.from_result,
  )
}

pub fn with_individual_values(pkm: Pkm, individual_values: Bytes) -> Pkm {
  Pkm(..pkm, individual_values: Some(pkm_bytes.get_ivs(individual_values)))
}

/// Uses the whole UnencryptedPkmBytes to build Pkm with effort values
///
/// As each effort_value is a field of UnencryptedPkmBytes,
/// each effort_value will be extracted from the `get_evs` function
///
pub fn with_effort_values(pkm: Pkm, bs: pkm_bytes.UnencryptedPkmBytes) -> Pkm {
  Pkm(..pkm, effort_values: Some(pkm_bytes.get_evs(bs)))
}

pub fn with_experience_points(pkm: Pkm, experience_points: Bytes) -> Pkm {
  Pkm(..pkm, experience_points: Some(bytes.to_int(experience_points)))
}

pub fn with_friendship(pkm: Pkm, friendship: Bytes) -> Pkm {
  Pkm(..pkm, friendship: Some(bytes.to_int(friendship)))
}

/// Gets the original language from the corresponding lookup table
///
pub fn with_original_language(pkm: Pkm, original_language: Bytes) -> Pkm {
  Pkm(
    ..pkm,
    original_language: option.from_result(lookup.lookup_ingame_str(
      original_language,
      game_info.language,
    )),
  )
}

fn get_generation(origin_game: Option(String)) -> Int {
  case option.unwrap(origin_game, "") {
    "Sapphire" | "Ruby" | "Emerald" -> 3
    "Colosseum/XD" | "Fire Red" | "Leaf Green" -> 3
    "Diamond" | "Pearl" | "Platinum" | "Heart Gold" | "Soul Silver" -> 4
    "White" | "Black" | "White 2" | "Black 2" -> 5
    "X" | "Y" -> 6
    _ -> 0
  }
}

/// Checks shininess according to
/// [Gen3+ algorithm](https://bulbapedia.bulbagarden.net/wiki/Personality_value#Shininess)
/// ```
/// S = OT_ID xor OT_SID xor PID{31..16} xor PID{15..0}
///   if gen{3..5}: S < 8
///   if gen{6.. }: S < 16
/// ```
///
pub fn is_shiny(gen: Int, pid: Int, ot_id: Int, secret_id: Int) -> Bool {
  let pid_upper16 = pid |> int.bitwise_shift_right(16)
  let pid_lower16 = pid |> int.bitwise_and(0xffff)

  let xored =
    ot_id
    |> int.bitwise_exclusive_or(secret_id)
    |> int.bitwise_exclusive_or(pid_upper16)
    |> int.bitwise_exclusive_or(pid_lower16)

  case gen {
    gen if gen <= 5 -> xored < 8
    _gen6_and_above -> xored < 16
  }
}

pub fn with_shiny(pkm: Pkm, pid: Bytes, ot_id: Bytes, secret_id: Bytes) -> Pkm {
  Pkm(
    ..pkm,
    shiny: Some(is_shiny(
      get_generation(pkm.origin_game),
      bytes.to_int(pid),
      bytes.to_int(ot_id),
      bytes.to_int(secret_id),
    )),
  )
}

pub fn with_level(pkm: Pkm, level: Bytes) -> Pkm {
  Pkm(..pkm, level: Some(bytes.to_int(level)))
}

/// Gets the nature from the corresponding lookup table
///
pub fn get_nature(pid: Int) -> Result(String, Nil) {
  pokemon_info.natures
  |> dict.from_list
  |> dict.get(pid % 25)
}

pub fn with_nature(pkm: Pkm, pid: Bytes) -> Pkm {
  Pkm(..pkm, nature: get_nature(bytes.to_int(pid)) |> option.from_result)
}

/// Gets the species from the corresponding lookup table
///
pub fn get_species(national_pokedex_id: Int) -> Result(String, Nil) {
  pokemon_info.species
  |> dict.from_list
  |> dict.get(national_pokedex_id)
}

pub fn with_species(pkm: Pkm, national_pokedex_id: Bytes) -> Pkm {
  Pkm(
    ..pkm,
    species: option.from_result(get_species(bytes.to_int(national_pokedex_id))),
  )
}

/// Compute hidden_power according to the
/// [following documentation](https://bulbapedia.bulbagarden.net/wiki/Hidden_Power_(move)/Calculation#Generation_III_onward)
///
/// `powr_bits` are computed using a quick trick:
/// `iv % 4 / 2`, rather than checking if `iv % 4 == 3 || iv % 4 == 2`
///
fn get_hidden_power(
  indiv_values: Option(pkm_bytes.IndividualValues),
) -> Option(pkm_bytes.HiddenPower) {
  indiv_values
  |> option.then(fn(i) {
    let ivs = [i.atk, i.def, i.hp, i.spa, i.spd, i.spe]

    let type_bits = list.map(ivs, fn(iv) { iv % 2 })
    let powr_bits = list.map(ivs, fn(iv) { iv % 4 / 2 })

    let sum_bits = fn(sum, bit, i) { sum + bit * int.bitwise_shift_left(1, i) }

    let hp_type = list.index_fold(type_bits, 0, sum_bits) * 15 / 63
    let hp_power = list.index_fold(powr_bits, 0, sum_bits) * 40 / 63 + 30

    pokemon_info.hidden_power_types
    |> dict.from_list
    |> dict.get(hp_type)
    |> option.from_result
    |> option.map(pkm_bytes.HiddenPower(_, hp_power))
  })
}

pub fn with_hidden_power(pkm: Pkm) -> Pkm {
  Pkm(..pkm, hidden_power: get_hidden_power(pkm.individual_values))
}

fn get_gender(encounter_main_info: Int) -> String {
  let _is_fateful_encounter = bytes.is_bit_set(encounter_main_info, 0)
  let is_female = bytes.is_bit_set(encounter_main_info, 1)
  let is_genderless = bytes.is_bit_set(encounter_main_info, 2)

  // TODO: handle alternate forms, and fateful encounters
  // rather than a simple default "Male" or "Genderless"
  // (handle Deoxys, Unown...)
  case encounter_main_info {
    _ if is_genderless -> "Genderless"
    _ if is_female -> "Female"
    _alternate_forms -> "Male"
  }
}

pub fn with_gender(pkm: Pkm, encounter_main_info: Bytes) -> Pkm {
  Pkm(..pkm, gender: Some(get_gender(bytes.to_int(encounter_main_info))))
}
