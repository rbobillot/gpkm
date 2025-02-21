import gleeunit/should
import utils/files

pub fn read_file_as_str_test() {
  let path_to_b64_pkm = "misc/chimchar_fr.pkm.b64"
  let path_to_bin_pkm = "misc/chimchar_fr.pkm"
  let path_to_non_existing_file = "/non/existing/file.txt"

  let chimchar_b64 =
    "PbLkNgAAN1KGAQAAB8k5xpcAAABGQgADAAAAAQAAAAAAAAAAAAAAAAoAKwAAAAAAIx4AAAAAAABh4Dc+AAAAAAAAAAAAAAAAOQE/ATMBPQE+ATMBLQE8ASsBNwH//wAKAAAAAAAAAABWAUkBSAFRAVMBUwFSAf//AAAACwEDAABMAAAEBQwAAAAAAAAFABMAEwALAAkACwAKAAoAAAAAAAADCv//////////////////////////////AAD//wAA////////AAD///////9qAf////8AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA="

  files.read_file_as_str(path_to_b64_pkm)
  |> should.equal(Ok(chimchar_b64 <> "\n"))

  files.read_file_as_str(path_to_bin_pkm)
  |> should.equal(Error(Nil))

  files.read_file_as_str(path_to_non_existing_file)
  |> should.be_error
}
