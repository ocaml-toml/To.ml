(**
   Partial lenses (returns [option]) for accessing TOML structures. They make it
   possible to read/write deeply nested immutable values.
 *)

type ('a, 'b) lens = {
  get: 'a -> 'b option;
  set: 'b -> 'a -> 'a option;
}

val (|-) : ('a -> 'b option) -> ('b -> 'c option) -> 'a -> 'c option

val modify : ('a, 'b) lens -> ('b -> 'b option) -> 'a -> 'a option

val compose : ('a, 'b) lens -> ('c, 'a) lens -> ('c, 'b) lens

val (|--) : ('a, 'b) lens -> ('b, 'c) lens -> ('a, 'c) lens

val get : 'a -> ('a, 'b) lens -> 'b option

val set : 'b  -> 'a -> ('a, 'b) lens -> 'a option

val key : string -> (TomlTypes.table, TomlTypes.value) lens

val string : (TomlTypes.value, string) lens

val bool : (TomlTypes.value, bool) lens

val int : (TomlTypes.value, int) lens

val float : (TomlTypes.value, float) lens

val date : (TomlTypes.value, float) lens

val array : (TomlTypes.value, TomlTypes.array) lens

val table : (TomlTypes.value, TomlTypes.table) lens

val strings : (TomlTypes.array, string list) lens

val bools : (TomlTypes.array, bool list) lens

val ints : (TomlTypes.array, int list) lens

val floats : (TomlTypes.array, float list) lens

val dates : (TomlTypes.array, float list) lens

val tables : (TomlTypes.array, TomlTypes.table list) lens

val arrays : (TomlTypes.array, TomlTypes.array list) lens
