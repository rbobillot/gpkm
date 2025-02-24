import gleeunit/should
import gpkm/pkm/pkm_builder

pub fn is_shiny_test() {
  let gen4 = 4
  let gen5 = 5
  let ot_id = 24_294
  let ot_sid = 38_834
  let pid = 2_814_471_828

  pkm_builder.is_shiny(gen4, pid, ot_id, ot_sid)
  |> should.equal(True)

  pkm_builder.is_shiny(gen5, pid, ot_id, ot_sid)
  |> should.equal(True)
}
