(**
  * Here is the main file of testing
  *)

open OUnit
open Toml
open TomlInternal
open TomlInternal.Type
module Toml_key = Toml.Table.Key

let table_find key_string = Table.find (Toml_key.of_string key_string)

let get_table tbl key = match table_find key tbl with
  | TTable t -> t
  | _ -> assert false

let _ =
  let assert_equal = OUnit.assert_equal ~printer:Dump.value in
  let suite = "Main tests" >:::
  [
    "Rache Methodology Approved" >::: [
       "simple key value" >:: (fun () ->
        let str = "key = \"VaLUe42\"" in
        let toml = Parser.from_string str in
        let var = table_find "key" toml in
        assert_equal (TString"VaLUe42") var;
        assert_bool "Bad grammar" (var <> (TString("value42"))));

      "Two keys value" >:: (fun () ->
        let str = "key = \"VaLUe42\"\nkey2=42" in
        let toml = Parser.from_string str in
        let var = table_find "key" toml and var2 = table_find "key2" toml in
        assert_equal (TString "VaLUe42") var;
        assert_equal (TInt 42) var2);

      "Int" >:: (fun () ->
        let str = "key = 42\nkey2=-42" in
        let toml = Parser.from_string str in
        assert_equal (TInt 42) (table_find "key" toml);
        assert_equal (TInt (-42)) (table_find "key2" toml));

      "Float key" >:: (fun () ->
        let str = "key = 3.141595\nkey2=-3.141595" in
        let toml = Parser.from_string str in
        assert_equal (TFloat 3.141595) (table_find "key" toml);
        assert_equal (TFloat (-3.141595)) (table_find "key2" toml));

      "Bool key" >:: (fun () ->
        let str = "key = true\nkey2=false" in
        let toml = Parser.from_string str in
        assert_equal (TBool true) (table_find "key" toml);
        assert_equal (TBool false) (table_find "key2" toml));

      "String" >:: (fun () ->
         assert_equal
           (TString "\b")
           (table_find "key" (Parser.from_string "key=\"\\b\""));
         assert_equal
           (TString "\t")
           (table_find "key" (Parser.from_string "key=\"\\t\""));
         assert_equal
           (TString "\n")
           (table_find "key" (Parser.from_string "key=\"\\n\""));
         assert_equal
           (TString "\r")
           (table_find "key" (Parser.from_string "key=\"\\r\""));
         assert_equal
           (TString "\"")
           (table_find "key" (Parser.from_string "key=\"\\\"\""));
         assert_equal
           (TString "\\")
           (table_find "key" (Parser.from_string "key=\"\\\\\""));
         assert_equal
           (TString "\\")
           (table_find "key" (Parser.from_string "key=\"\\\\\""));
         assert_raises
           (Failure "Forbidden escaped char")
           (fun () -> Parser.from_string "key=\"\\j\"");
         assert_raises
           (Failure "Unterminated string")
           (fun () -> Parser.from_string "key=\"This string is not termin"));

      "Array key" >:: (fun () ->
        let str = "key = [true, true, false, true]" in
        let toml = Parser.from_string str in
        let var = table_find "key" toml in
        assert_equal (TArray(NodeBool([true; true; false; true]))) var;
        let str = "key = []" in
        let toml = Parser.from_string str in
        let var = table_find "key" toml in
        assert_equal (TArray(NodeEmpty)) var;
        let str = "key = [true, true,]" in
        let toml = Parser.from_string str in
        let var = table_find "key" toml in
        assert_equal (TArray(NodeBool([true; true]))) var);

        "Nested Arrays" >:: (fun () ->
        let str ="key=[ [1,2],[\"a\",\"b\",\"c\",\"d\"]\n,[] ]" in
        let toml = Parser.from_string str in
        assert_equal
          (TArray(NodeArray([NodeInt([1; 2]);
                             NodeString(["a";"b";"c";"d"]);
                             NodeEmpty])))
          (table_find "key" toml));

      "Grouped key" >:: (fun () ->
        let str = "[group1]\nkey = true\nkey2 = 1337" in
        let toml = Parser.from_string str in
        assert_raises Not_found (fun () -> table_find "key" toml);
        let group1 = get_table toml "group1" in
        assert_equal (TBool true) (table_find "key" group1);
        assert_equal (TInt 1337) (table_find "key2" group1));

      "Comment" >:: (fun () ->
        let str = "[group1]\nkey = true # this is comment" in
        let toml = Parser.from_string str in
        let group1 = get_table toml "group1" in
        assert_equal (TBool true) (table_find "key" group1));

      "Date" >:: (fun () ->
        let str = "[group1]\nkey = 1979-05-27T07:32:00Z" in
        let toml = Parser.from_string str in
        let group1 = get_table toml "group1" in
         assert_equal
           (TDate {Unix.tm_year=79;Unix.tm_mon=04;Unix.tm_mday=27;
                   Unix.tm_hour=07;Unix.tm_min=32;Unix.tm_sec=0;
                   Unix.tm_wday=(-1);Unix.tm_yday=(-1);
                   Unix.tm_isdst=true;})
           (table_find "key" group1));

      "Same key, different group" >:: (fun () ->
        let str = "key=1[group]\nkey = 2" in
        let toml = Parser.from_string str in
        assert_equal
          (TInt 1)
          (table_find "key" toml);
        assert_equal
          (TInt 2)
          (table_find "key" (get_table toml "group")));

      "Unicode" >:: (fun () ->
        let str = "key=\"\\u03C9\"\nkey2=\"\\u4E2D\\u56FD\\u0021\"" in
        let toml = Parser.from_string str in
        assert_equal
          (TString "ω")
          (table_find "key" toml);
        assert_equal
          (TString "中国!")
          (table_find "key2" toml));

  ];
    (* "Lexer" >:::                                                 *)
    (* [                                                            *)
    (*   "Detect strings" >:: (fun () -> OUnit.todo "Not yet !");   *)
    (*   "Detect int" >:: (fun () -> OUnit.todo "Not yet !");       *)
    (*   "Detect floats" >:: (fun () -> OUnit.todo "Not yet !");    *)
    (*   "Detect booleans" >:: (fun () -> OUnit.todo "Not yet !");  *)
    (*   "Detect dates" >:: (fun () -> OUnit.todo "Not gf yet !");  *)
    (*   "Detect comments" >:: (fun () -> OUnit.todo "Not yet !");  *)
    (* ];                                                           *)

    (* "Parsing" >:::                                               *)
    (* [                                                            *)
    (*   "Parse arrays" >:: (fun () -> OUnit.todo "Not yet !");     *)
    (*   "Parse key values" >:: (fun () -> OUnit.todo "Not yet !"); *)
    (*   "Parse Groups" >:: (fun () -> OUnit.todo "Not yet !");     *)
    (*   "Parse Sub-groups" >:: (fun () -> OUnit.todo "Not yet !"); *)
    (* ];                                                           *)

    (* "Huge files" >::: []                                         *)
  ] in
  OUnit.run_test_tt_main suite
