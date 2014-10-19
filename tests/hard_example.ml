open OUnit
open Toml
open TomlInternal
open TomlInternal.Type

module Toml_key = Toml.Table.Key

let error1 ="string = \"Anything other than tabs, spaces and newline after a keygroup or key value pair has ended should produce an error unless it is a comment\"   like this"

let error2 ="array = [
         \"This might most likely happen in multiline arrays\",
         Like here,
         \"or here,
         and here\"
         ]     End of array comment, forgot the #"

let error3 ="number = 3.14  pi <--again forgot the #"

let toml = Parser.from_channel stdin

let mk_table x =
  TTable (List.fold_left (fun tbl (k,v) -> Table.add (Toml_key.of_string k) v tbl) Table.empty x)

let assert_equal =
  OUnit.assert_equal ~cmp:Equal.table ~printer:Dump.table

let expected =
  List.fold_left (fun tbl (k,v) -> Table.add k v tbl) Table.empty
    [
      Toml_key.of_string "the", mk_table
        [ "test_string", TString "You'll hate me after this - #" ;

          "hard", mk_table
            [ "test_array", TArray (NodeString ["] "; " # " ]) ;
              "test_array2", TArray (NodeString
                                       ["Test #11 ]proved that" ;
                                        "Experiment #9 was a success"]) ;
              "another_test_string",
              TString " Same thing, but with a string #" ;
              "harder_test_string",
              TString " And when \"'s are in the string, along with # \"" ;
              "bit", mk_table
                ["what?", TString "You don't think some user won't do that?";
                 "multi_line_array", TArray (NodeString ["]"])]
            ]
        ]
    ]

let test = "Official hard_example.toml file" >:::
  [

    "Success" >:: (fun () -> assert_equal expected toml) ;

    "Error" >:: (fun () ->
      assert_raises
        (TomlParser.Error)
        (fun () -> ignore(Parser.from_string error1));
      assert_raises
        (TomlParser.Error)
        (fun () -> ignore(Parser.from_string error2));
      assert_raises
        (TomlParser.Error)
        (fun () -> ignore(Parser.from_string error3)))

  ]

let _ = OUnit.run_test_tt_main test
