import gleam/bit_array
import gleam/option.{None, Some}
import gleam/result
import gleeunit/should
import gpkm/pkm/pkm_builder
import gpkm/pkm/pkm_bytes.{
  B64, EffortValues, HiddenPower, IndividualValues, Move, Moves, PkmBits,
}
import gpkm/pkm/ser_de
import gpkm/sav/decrypt
import gpkm/utils/bytes
import gpkm/utils/files

const chimchar_fr_pkm_file_path_sav = "misc/chimchar_fr.pkm.sav"

const chimchar_fr_pkm_file_path_sav_b64 = "misc/chimchar_fr.pkm.sav.b64"

// sav_file_path_b64 contains example's chimchar
// at offset 0x40098
const sav_file_path = "misc/pokemon_diamond_fr.nds.sav"

const chimchar_fr_pkm_sav_b64 = "
  PbLkNgAAN1I8p+PP4frwr5vXUfuXXv8ivoONZT2wNDNaMMB3Xnxnn+5IiOqchgOMmwvQ4FkP/wiO
  6c6N5Z6hrSDQMTSRcqHGnqYIH/9/y8Qd8utgN5OFGFqJBZVxH/iwC6F4VaAsyQfXzAHHULOiKiSX
  hnWP6ueigJ4KWt3BxcI+r2oyMkk9NtxlHgXUnKkuLQw3c669SeTZzqS6YUIeWIOVSWYj4CC7aiOU
  g95LRRGvDfIFXi+FxRrhlwI/27g/c0iq32gzSsoTavmnCviSf0BvU4GnXXWXtdqjGPmujWmZa/UV
  e/+aLbLX7P8=
"

const chimchar_fr_pkm = pkm_builder.Pkm(
  pid: Some(920_957_501),
  nickname: Some("OUISTICRAM"),
  national_pokedex_id: Some(390),
  held_item: Some("Nothing"),
  origin_game: Some("Diamond"),
  ot_name: Some("redmoon"),
  ot_id: Some(51_463),
  ot_secret_id: Some(50_745),
  moves: Some(
    Moves(Some(Move("Scratch", 35)), Some(Move("Leer", 30)), None, None),
  ),
  ability: Some("Blaze"),
  individual_values: Some(IndividualValues(1, 3, 24, 15, 3, 31)),
  effort_values: Some(EffortValues(0, 0, 0, 1, 0, 0)),
  experience_points: Some(151),
  friendship: Some(70),
  original_language: Some("Français (France/Québec)"),
  shiny: Some(False),
  level: Some(5),
  nature: Some("Lonely"),
  species: Some("Chimchar"),
  gender: Some("Male"),
  hidden_power: Some(HiddenPower("Dragon", 66)),
  b64_pkm_data: "PbLkNgAAN1KGAQAAB8k5xpcAAABGQgADAAAAAQAAAAAAAAAAAAAAAAoAKwAAAAAAIx4AAAAAAABh4Dc+AAAAAAAAAAAAAAAAOQE/ATMBPQE+ATMBLQE8ASsBNwH//wAKAAAAAAAAAABWAUkBSAFRAVMBUwFSAf//AAAACwEDAABMAAAEBQwAAAAAAAAFABMAEwALAAkACwAKAAoAAAAAAAADCv//////////////////////////////AAD//wAA////////AAD///////9qAf////8AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA=",
)

pub fn decrypt_test() {
  // TODO: rather than calling transformations (b64 serde, bits...)
  // they should be called within a parametrized `decrypt_pkm(PkmSav...)` function
  // like the `read_pkm(PkmSav...)` function
  chimchar_fr_pkm_sav_b64
  |> ser_de.deserialize_b64
  |> result.map(decrypt.decrypt_pkm)
  |> result.map(bytes.bytes_to_bits)
  |> result.map(bit_array.base64_encode(_, True))
  |> result.map(ser_de.read_pkm(_, PkmBits(B64)))
  |> should.equal(chimchar_fr_pkm |> Ok |> Ok)

  files.read_file_as_str(chimchar_fr_pkm_file_path_sav_b64)
  |> result.then(ser_de.deserialize_b64)
  |> result.map(decrypt.decrypt_pkm)
  |> result.map(bytes.bytes_to_bits)
  |> result.map(bit_array.base64_encode(_, True))
  |> result.map(ser_de.read_pkm(_, PkmBits(B64)))
  |> should.equal(chimchar_fr_pkm |> Ok |> Ok)

  files.read_file(chimchar_fr_pkm_file_path_sav)
  |> result.map(decrypt.decrypt_pkm)
  |> result.map(bytes.bytes_to_bits)
  |> result.map(bit_array.base64_encode(_, True))
  |> result.map(ser_de.read_pkm(_, PkmBits(B64)))
  |> should.equal(chimchar_fr_pkm |> Ok |> Ok)

  // sav_file_path contains example's chimchar
  // at offset 0x40098
  files.read_file(sav_file_path)
  |> result.then(bit_array.slice(_, 0x40098, 236))
  |> result.map(decrypt.decrypt_pkm)
  |> result.map(bytes.bytes_to_bits)
  |> result.map(bit_array.base64_encode(_, True))
  |> result.map(ser_de.read_pkm(_, PkmBits(B64)))
  |> should.equal(chimchar_fr_pkm |> Ok |> Ok)
}
