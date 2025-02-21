import gleam/dict
import utils/bytes

/// Get a lookup table (mainly from pkm_lookup_tables)
/// converts it to a dictionary,
/// and get the string corresponding to the in-game bytes key
///
pub fn lookup_ingame_str(
  key: bytes.Bytes,
  lookup table: List(#(Int, String)),
) -> Result(String, Nil) {
  table
  |> dict.from_list
  |> dict.get(bytes.to_int(key))
}
