open OUnit
open Toml
open TomlInternal
open TomlInternal.Type

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
  TTable (List.fold_left (fun tbl (k,v) -> Table.add k v tbl) Table.empty x)

let assert_equal =
  OUnit.assert_equal ~cmp:Equal.table ~printer:Dump.table

let expected =
  List.fold_left (fun tbl (k,v) -> Table.add k v tbl) Table.empty
    [
      "title", TString "TOML Example" ;
      "owner", mk_table
        ["name", TString "Tom Preston-Werner";
         "organization", TString "GitHub";
         "bio", TString "GitHub Cofounder & CEO\n\
                         Likes tater tots and beer.";
         "dob", TDate { Unix.tm_year=79; tm_mon=04; tm_mday=27;
                        tm_hour=07; tm_min=32; tm_sec=0;
                        tm_wday=(-1); tm_yday=(-1); tm_isdst=true }] ;
      "database", mk_table
        ["server", TString "192.168.1.1" ;
          "ports", TArray (NodeInt [8001; 8001; 8002]) ;
          "connection_max", TInt 5000;
          "enabled", TBool true] ;
      "servers", mk_table
        [ "alpha", mk_table ["ip", TString "10.0.0.1" ;
                             "dc", TString "eqdc10" ] ;
          "beta", mk_table ["ip", TString "10.0.0.2";
                            "dc", TString "eqdc10";
                            "country", TString "中国" ] ] ;
      "clients", mk_table
        ["data", TArray (NodeArray [ NodeString ["gamma"; "delta"];
                                     NodeInt [1; 2] ]);
         "hosts", TArray (NodeString ["alpha"; "omega"]) ]
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
