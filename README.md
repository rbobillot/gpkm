# gpkm

A Gleam PKM reader

[![Package Version](https://img.shields.io/hexpm/v/gpkm)](https://hex.pm/packages/gpkm)
[![Hex Docs](https://img.shields.io/badge/hex-docs-ffaff3)](https://hexdocs.pm/gpkm/)

```sh
gleam add gpkm
```

## What is it ?

A simple deserializer, to read PKM data (Gen4, Gen5):

- `.pkm`, `.pk4`, `.pk5`, `.sav` (experimental) files
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

More examples in the [ser_de_test.gleam](./test/pkm/ser_de_test.gleam) file

Further documentation can be found at <https://hexdocs.pm/gpkm>.

## Development

```sh
gleam run   # Run the project
gleam test  # Run the tests
```
