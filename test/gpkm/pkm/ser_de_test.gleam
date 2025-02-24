import gleam/bit_array
import gleam/option.{None, Some}
import gleeunit/should
import gpkm/pkm/pkm_builder
import gpkm/pkm/pkm_bytes.{
  EffortValues, HiddenPower, IndividualValues, Move, Moves,
}
import gpkm/pkm/ser_de

const chimchar_fr_pkm_file_path = "misc/chimchar_fr.pkm"

const chimchar_fr_pkm_file_path_b64 = "misc/chimchar_fr.pkm.b64"

const chimchar_fr_pkm_b64 = "
  PbLkNgAAN1KGAQAAB8k5xpcAAABGQgADAAAAAQAAAAAAAAAAAAAAAAoAKwAAAAAAIx4AAAAAAABh
  4Dc+AAAAAAAAAAAAAAAAOQE/ATMBPQE+ATMBLQE8ASsBNwH//wAKAAAAAAAAAABWAUkBSAFRAVMB
  UwFSAf//AAAACwEDAABMAAAEBQwAAAAAAAAFABMAEwALAAkACwAKAAoAAAAAAAADCv//////////
  ////////////////////AAD//wAA////////AAD///////9qAf////8AAAAAAAAAAAAAAAAAAAAA
  AAAAAAAAAAA=
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

pub fn deserialize_b64_test() {
  let hello_test = "hello test\n" |> bit_array.from_string |> Ok

  let single_line_b64_hello_test = "aGVsbG8gdGVzdAo="

  let multi_line_b64_hello_test =
    "
    aGVsb
    G8gdG
    VzdAo
    =
    "

  ser_de.deserialize_b64(single_line_b64_hello_test)
  |> should.equal(hello_test)

  ser_de.deserialize_b64(multi_line_b64_hello_test)
  |> should.equal(hello_test)
}

pub fn read_pkm_test() {
  chimchar_fr_pkm_b64
  |> ser_de.read_pkm(pkm_bytes.PkmBits(pkm_bytes.B64))
  |> should.equal(Ok(chimchar_fr_pkm))

  chimchar_fr_pkm_file_path
  |> ser_de.read_pkm(pkm_bytes.PkmFile(pkm_bytes.Bin))
  |> should.equal(Ok(chimchar_fr_pkm))

  chimchar_fr_pkm_file_path_b64
  |> ser_de.read_pkm(pkm_bytes.PkmFile(pkm_bytes.B64))
  |> should.equal(Ok(chimchar_fr_pkm))

  "unknown_path"
  |> ser_de.read_pkm(pkm_bytes.PkmFile(pkm_bytes.Bin))
  |> should.equal(Error(ser_de.ReadError(pkm_bytes.PkmFile(pkm_bytes.Bin))))

  chimchar_fr_pkm_file_path
  |> ser_de.read_pkm(pkm_bytes.PkmFile(pkm_bytes.B64))
  |> should.equal(Error(ser_de.ReadError(pkm_bytes.PkmFile(pkm_bytes.B64))))
}
