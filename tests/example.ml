open OUnit
open Toml
open Utils

(** FIXME: Printed output has no diff but equality test fails. *)

(* This test file expects example.toml from official toml repo read *)
let toml = Parser.from_filename "./example.toml"

let test expected testing =
  fun () ->  OUnit.assert_equal
               ~cmp:(fun x y -> Compare.table x y == 0)
               ~printer:(fun x -> let buf = Buffer.create 42 in
                                  Printer.table
			            (Format.formatter_of_buffer buf) x ;
		                  Buffer.contents buf)
               expected testing

let expected =
  create_table
    [ bk"title",
      of_string "TOML Example" ;

      bk"owner",
      create_table_as_value
        [ bk"name", of_string "Tom Preston-Werner";
          bk"organization", of_string "GitHub";
          bk"bio", of_string "GitHub Cofounder & CEO\n\
                              Likes tater tots and beer.";
          bk"dob", of_date 296638320. (* 1979-05-27T07:32:00 *) ] ;

      bk"database",
      create_table_as_value
        [ bk"server", of_string "192.168.1.1" ;
          bk"ports", of_int_array [8001; 8001; 8002] ;
          bk"connection_max", of_int 5000;
          bk"enabled", of_bool true] ;

      bk"servers",
      create_table_as_value
        [ bk"alpha",
          create_table_as_value [bk"ip", of_string "10.0.0.1" ;
                                 bk"dc", of_string "eqdc10" ] ;
          bk"beta",
          create_table_as_value [bk"ip", of_string "10.0.0.2";
                                 bk"dc", of_string "eqdc10";
                                 bk"country", of_string "中国" ] ] ;

      bk"clients",
      create_table_as_value
        [ bk"data", of_array_array [
                        V.Of.Array.string ["gamma"; "delta"];
                        V.Of.Array.int [1; 2] ];
          bk"hosts", of_string_array ["alpha"; "omega"] ];

      bk"products",
      of_table_array [ create_table [
                           bk"name", of_string "Hammer";
                           bk"sku", of_int 738594937];
                       create_table [
                           bk"name", of_string "Nail";
                           bk"sku", of_int 284758393;
                           bk"color", of_string "gray"] ] ;
    ]


let suite =
  "Official example.toml file" >:::
    [ "example.toml parsing" >:: test toml expected ; ]
