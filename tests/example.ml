open OUnit
open Toml
module Toml_key = Toml.Table.Key

(* This test file expects example.toml from official toml repo read *)

let table_array_input =
"# Products (Not supported by To.ml)

  [[products]]
#  name = \"Hammer\"
#  sku = 738594937

#  [[products]]
#  name = \"Nail\"
#  sku = 284758393
#  color = \"gray\"
"

let toml = Parser.from_channel stdin

let mk_table x =
  Toml.Value.Of.table (List.fold_left (fun tbl (k,v) -> Table.add (Toml_key.of_string k) v tbl) Table.empty x)

let assert_equal =
  OUnit.assert_equal ~cmp:(fun x y -> Compare.table x y == 0)

let expected =
  List.fold_left (fun tbl (k,v) -> Table.add k v tbl) Table.empty
    [
      Toml_key.of_string "title", Toml.Value.Of.string "TOML Example" ;
      Toml_key.of_string "owner", mk_table
        ["name", Toml.Value.Of.string "Tom Preston-Werner";
         "organization", Toml.Value.Of.string "GitHub";
         "bio", Toml.Value.Of.string "GitHub Cofounder & CEO\n\
                         Likes tater tots and beer.";
         "dob", Toml.Value.Of.date { Unix.tm_year=79; tm_mon=04; tm_mday=27;
                        tm_hour=07; tm_min=32; tm_sec=0;
                        tm_wday=(-1); tm_yday=(-1); tm_isdst=true }] ;
      Toml_key.of_string "database", mk_table
        ["server", Toml.Value.Of.string "192.168.1.1" ;
          "ports", Toml.Value.Of.array (Toml.Value.Of.Array.int [8001; 8001; 8002]) ;
          "connection_max", Toml.Value.Of.int 5000;
          "enabled", Toml.Value.Of.bool true] ;
      Toml_key.of_string "servers", mk_table
        [ "alpha", mk_table ["ip", Toml.Value.Of.string "10.0.0.1" ;
                             "dc", Toml.Value.Of.string "eqdc10" ] ;
          "beta", mk_table ["ip", Toml.Value.Of.string "10.0.0.2";
                            "dc", Toml.Value.Of.string "eqdc10";
                            "country", Toml.Value.Of.string "中国" ] ] ;
      Toml_key.of_string "clients", mk_table
        ["data", Toml.Value.Of.array (Toml.Value.Of.Array.array [
          Toml.Value.Of.Array.string ["gamma"; "delta"];
                                     Toml.Value.Of.Array.int [1; 2] ]);
         "hosts", Toml.Value.Of.array (Toml.Value.Of.Array.string ["alpha"; "omega"]) ]
    ]


let test = "Official example.toml file" >:::
           [
             "example.toml parsing" >::
             (fun () -> assert_equal toml expected) ;
             "Array of table" >:: (fun () ->
                 assert_raises
                   (Failure "Array of tables is not supported")
                   (fun () -> ignore(Parser.from_string table_array_input)))
           ]
let _ = OUnit.run_test_tt_main test

