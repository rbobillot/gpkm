import gleam/io
import pkm/pkm_bytes.{Bin, PkmFile}
import pkm/ser_de.{read_pkm}

pub fn main() {
  let chimchar_fr_pkm_path = "misc/chimchar_fr.pkm"

  let _pkm = read_pkm(chimchar_fr_pkm_path, PkmFile(Bin)) |> io.debug
}
