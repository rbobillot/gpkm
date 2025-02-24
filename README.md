# gpkm

A Gleam PKM reader

[![Package Version](https://img.shields.io/hexpm/v/gpkm)](https://hex.pm/packages/gpkm)
[![Hex Docs](https://img.shields.io/badge/hex-docs-ffaff3)](https://hexdocs.pm/gpkm/)

```sh
gleam add gpkm
```

## What is it ?

A simple deserializer, to read PKM data (Gen4, Gen5):

- `.pkm`, `.pk4`, `.pk5` (soon), `.sav` (experimental) files
- `base64` pkm strings (.pkm bytes as base64)
- `base64` pkm files

The read data is used to craft a `Pkm` record,
containing human readable data:

```gleam
  Pkm(
    pid: Option(Int),
    nickname: Option(String),
    national_pokedex_id: Option(Int),
    held_item: Option(String),
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
```

## Motivation

Actually, mostly for fun

I've made a few ones in other languages (Scala, Python, Zig...),
but I wanted to make one in Gleam

But, I'm also gonna make a little web service to display info, from a PKM file,
this tool will be used to convert PKM data to JSON

It will evolve later:

- better documentation
- more test coverage
- better decrypt logic
- add encrypt logic

## Usage

```gleam
import gleam/io
import gpkm/pkm/pkm_bytes.{B64, Bin, PkmBits, PkmFile}
import gpkm/pkm/ser_de.{read_pkm}

pub fn main() {
  let chimchar_fr_pkm_path = "misc/chimchar_fr.pkm"

  let chimchar_fr_pkm_b64 = "
    PbLkNgAAN1KGAQAAB8k5xpcAAABGQgADAAAAAQAAAAAAAAAAAAAAAAoAKwAAAAAAIx4AAAAAAABh
    4Dc+AAAAAAAAAAAAAAAAOQE/ATMBPQE+ATMBLQE8ASsBNwH//wAKAAAAAAAAAABWAUkBSAFRAVMB
    UwFSAf//AAAACwEDAABMAAAEBQwAAAAAAAAFABMAEwALAAkACwAKAAoAAAAAAAADCv//////////
    ////////////////////AAD//wAA////////AAD///////9qAf////8AAAAAAAAAAAAAAAAAAAAA
    AAAAAAAAAAA=
  "

  let _pkm = read_pkm(chimchar_fr_pkm_path, PkmFile(Bin)) |> io.debug

  let _pkm = read_pkm(chimchar_fr_pkm_b64, PkmBits(B64)) |> io.debug
}
```

More examples in the
[ser_de_test.gleam](https://github.com/rbobillot/gpkm/blob/main/test/gpkm/pkm/ser_de_test.gleam)
file

## Serialize data (JSON is the way, using gleam_json)

```gleam
import gleam/json
import gpkm/pkm/pkm_builder

// gpkm@1.1.1
fn pkm_to_json(pkm: pkm_builder.Pkm) -> String {
  json.object([
    #("pid", json.nullable(pkm.pid, json.int)),
    #("nickname", json.nullable(pkm.nickname, json.string)),
    #("national_pokedex_id", json.nullable(pkm.national_pokedex_id, json.int)),
    #("held_item", json.nullable(pkm.held_item, json.string)),
    #("origin_game", json.nullable(pkm.origin_game, json.string)),
    #("ot_name", json.nullable(pkm.ot_name, json.string)),
    #("ot_id", json.nullable(pkm.ot_id, json.int)),
    #("ot_secret_id", json.nullable(pkm.ot_secret_id, json.int)),
    #(
      "moves",
      json.nullable(pkm.moves, fn(moves) {
        json.object(
          [
            #("move_1", moves.move_1),
            #("move_2", moves.move_2),
            #("move_3", moves.move_3),
            #("move_4", moves.move_4),
          ]
          |> list.map(fn(move_n) {
            #(
              move_n.0,
              json.nullable(move_n.1, fn(mv) {
                json.object([
                  #("name", json.string(mv.name)),
                  #("pp", json.int(mv.pp)),
                ])
              }),
            )
          }),
        )
      }),
    ),
    #("ability", json.nullable(pkm.ability, json.string)),
    #(
      "individual_values",
      json.nullable(pkm.individual_values, fn(iv) {
        json.object([
          #("hp", json.int(iv.hp)),
          #("atk", json.int(iv.atk)),
          #("def", json.int(iv.def)),
          #("spe", json.int(iv.spe)),
          #("spa", json.int(iv.spa)),
          #("spd", json.int(iv.spd)),
        ])
      }),
    ),
    #(
      "effort_values",
      json.nullable(pkm.effort_values, fn(ev) {
        json.object([
          #("hp", json.int(ev.hp)),
          #("atk", json.int(ev.atk)),
          #("def", json.int(ev.def)),
          #("spe", json.int(ev.spe)),
          #("spa", json.int(ev.spa)),
          #("spd", json.int(ev.spd)),
        ])
      }),
    ),
    #("experience_points", json.nullable(pkm.experience_points, json.int)),
    #("friendship", json.nullable(pkm.friendship, json.int)),
    #("original_language", json.nullable(pkm.original_language, json.string)),
    #("shiny", json.nullable(pkm.shiny, json.bool)),
    #("level", json.nullable(pkm.level, json.int)),
    #("nature", json.nullable(pkm.nature, json.string)),
    #("species", json.nullable(pkm.species, json.string)),
    #("gender", json.nullable(pkm.gender, json.string)),
    #(
      "hidden_power",
      json.nullable(pkm.hidden_power, fn(hp) {
        json.object([
          #("power_type", json.string(hp.power_type)),
          #("base_power", json.int(hp.base_power)),
        ])
      }),
    ),
    #("b64_pkm_data", json.string(pkm.b64_pkm_data)),
  ])
  |> json.to_string
}

let _pkm =
  read_pkm(chimchar_fr_pkm_b64, PkmBits(B64))
  |> result.map(pkm_to_json)
  |> result.unwrap("{}")
  |> io.println
// -> {"pid":920957501,"nickname":"OUISTICRAM","national_pokedex_id":390,"held_item":"Nothing","origin_game":"Diamond","ot_name":"redmoon","ot_id":51463,"ot_secret_id":50745,"moves":{"move_1":{"name":"Scratch","pp":35},"move_2":{"name":"Leer","pp":30},"move_3":null,"move_4":null},"ability":"Blaze","individual_values":{"hp":1,"atk":3,"def":24,"spe":15,"spa":3,"spd":31},"effort_values":{"hp":0,"atk":0,"def":0,"spe":1,"spa":0,"spd":0},"experience_points":151,"friendship":70,"original_language":"Français (France/Québec)","shiny":false,"level":5,"nature":"Lonely","species":"Chimchar","gender":"Male","hidden_power":{"power_type":"Dragon","base_power":66},"b64_pkm_data":"PbLkNgAAN1KGAQAAB8k5xpcAAABGQgADAAAAAQAAAAAAAAAAAAAAAAoAKwAAAAAAIx4AAAAAAABh4Dc+AAAAAAAAAAAAAAAAOQE/ATMBPQE+ATMBLQE8ASsBNwH//wAKAAAAAAAAAABWAUkBSAFRAVMBUwFSAf//AAAACwEDAABMAAAEBQwAAAAAAAAFABMAEwALAAkACwAKAAoAAAAAAAADCv//////////////////////////////AAD//wAA////////AAD///////9qAf////8AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA="}
```

Further documentation can be found at <https://hexdocs.pm/gpkm>.

## Development

```sh
gleam run   # Run the project
gleam test  # Run the tests
```
