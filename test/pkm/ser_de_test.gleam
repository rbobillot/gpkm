import gleam/bit_array
import gleam/option.{Some}
import gleeunit/should
import pkm/pkm_builder
import pkm/pkm_bytes.{EffortValues, HiddenPower, IndividualValues, Move, Moves}
import pkm/ser_de

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
  Some(920_957_501),
  Some("OUISTICRAM"),
  Some(390),
  Some("Nothing"),
  Some("redmoon"),
  Some(51_463),
  Some(50_745),
  Some(
    Moves(Ok(Move("Scratch", 35)), Ok(Move("Leer", 30)), Error(Nil), Error(Nil)),
  ),
  Some("Blaze"),
  Some(IndividualValues(1, 3, 24, 15, 3, 31)),
  Some(EffortValues(0, 0, 0, 1, 0, 0)),
  Some(151),
  Some(70),
  Some("Français (France/Québec)"),
  Some(False),
  Some(5),
  Some("Lonely"),
  Some("Chimchar"),
  Some("Male"),
  Some(HiddenPower("Dragon", 66)),
  "PbLkNgAAN1KGAQAAB8k5xpcAAABGQgADAAAAAQAAAAAAAAAAAAAAAAoAKwAAAAAAIx4AAAAAAABh4Dc+AAAAAAAAAAAAAAAAOQE/ATMBPQE+ATMBLQE8ASsBNwH//wAKAAAAAAAAAABWAUkBSAFRAVMBUwFSAf//AAAACwEDAABMAAAEBQwAAAAAAAAFABMAEwALAAkACwAKAAoAAAAAAAADCv//////////////////////////////AAD//wAA////////AAD///////9qAf////8AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA=",
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
}
