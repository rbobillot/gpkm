//// In the PKM file, some of the Game data (language, game) are single-bytes values.
////
//// This file is a collection of lookup tables, for each game datum
////

pub const language = [
  #(0x1, "日本語 (Japan)"),
  #(0x2, "English (US/UK/AU)"),
  #(0x3, "Français (France/Québec)"),
  #(0x4, "Italiano (Italy)"),
  #(0x5, "Deutsch (Germany)"),
  #(0x6, "Español (Spain/Latin Americas)"),
  #(0x7, "한국어 (South Korea)"),
]

pub const game = [
  #(0, "None"),
  #(1, "Sapphire"),
  #(2, "Ruby"),
  #(3, "Emerald"),
  #(4, "Fire Red"),
  #(5, "Leaf Green"),
  #(7, "Heart Gold"),
  #(8, "Soul Silver"),
  #(10, "Diamond"),
  #(11, "Pearl"),
  #(12, "Platinum"),
  #(15, "Colosseum/XD"),
  #(20, "White"),
  #(21, "Black"),
  #(22, "White 2"),
  #(23, "Black 2"),
  #(24, "X"),
  #(25, "Y"),
]
