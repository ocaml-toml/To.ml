open Toml
open OUnit
module T = Toml.Table
module V = Toml.Value
module K = Toml.Table.Key

let bk = K.bare_key_of_string
let qk = K.quoted_key_of_string

let assert_table_equal expected testing =
  OUnit.assert_equal
               ~cmp:(fun x y -> Compare.table x y == 0)
               ~printer:(fun x -> let buf = Buffer.create 42 in
                                  Printer.table
			            (Format.formatter_of_buffer buf) x ;
		                  Buffer.contents buf)
               expected testing

(* Create a new table containing [kvs], a key-value list. *)
(* Use List.rev because otherwise = complains, ugh *)
let create_table kvs =
  List.fold_left (fun t (k, v) -> T.add k v t) T.empty (List.rev kvs)

(* Same as [create_table], but return table as [value] instead of [table]. *)
let create_table_as_value kvs =
  of_table (create_table kvs)

let mk_printer fn =
  fun x ->
  let b = Buffer.create 100 in
  let fmt = Format.formatter_of_buffer b in
  fn fmt x;
  Buffer.contents b

let string_of_table = mk_printer Toml.Printer.table
let string_of_value = mk_printer Toml.Printer.value
let string_of_array = mk_printer Toml.Printer.array

let toml_table key_values =
  create_table key_values |> string_of_table

let test_string = assert_equal ~printer:(fun x -> x)
let test_int = assert_equal ~printer:string_of_int
let test_float = assert_equal ~printer:string_of_float
let test_bool = assert_equal ~printer:string_of_bool
