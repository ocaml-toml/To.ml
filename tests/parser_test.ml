(**
  * Here is the main file of testing
  *)

open OUnit
open TomlType
open TomlPprint
open Toml

let _ =
  let assert_equal = OUnit.assert_equal ~printer:string_of_val in
  let suite = "Main tests" >:::
  [
    "Rache Methodology Approved" >::: [
       "simple key value" >:: (fun () ->
        let str = "key = \"VaLUe42\"" in
        let toml = Toml.from_string str in
        let var = Hashtbl.find toml "key" in
        assert_equal (TString"VaLUe42") var;
        assert_bool "Bad grammar" (var <> (TString("value42"))));

      "Two keys value" >:: (fun () ->
        let str = "key = \"VaLUe42\"\nkey2=42" in
        let toml = Toml.from_string str in
        let var = Hashtbl.find toml "key" and var2 = Hashtbl.find toml "key2" in
        assert_equal (TString "VaLUe42") var;
        assert_equal (TInt 42) var2);

      "Int" >:: (fun () ->
        let str = "key = 42\nkey2=-42" in
        let toml = Toml.from_string str in
        assert_equal (TInt 42) (Hashtbl.find toml "key");
        assert_equal (TInt (-42)) (Hashtbl.find toml "key2"));

      "Float key" >:: (fun () ->
        let str = "key = 3.141595\nkey2=-3.141595" in
        let toml = Toml.from_string str in
        assert_equal (TFloat 3.141595) (Hashtbl.find toml "key");
        assert_equal (TFloat (-3.141595)) (Hashtbl.find toml "key2"));

      "Bool key" >:: (fun () ->
        let str = "key = true\nkey2=false" in
        let toml = Toml.from_string str in
        assert_equal (TBool true) (Hashtbl.find toml "key");
        assert_equal (TBool false) (Hashtbl.find toml "key2"));

      "String" >:: (fun () ->
         assert_equal
           (TString "\b")
           (Hashtbl.find (Toml.from_string "key=\"\\b\"") "key");
         assert_equal
           (TString "\t")
           (Hashtbl.find (Toml.from_string "key=\"\\t\"") "key");
         assert_equal
           (TString "\n")
           (Hashtbl.find (Toml.from_string "key=\"\\n\"") "key");
         assert_equal
           (TString "\r")
           (Hashtbl.find (Toml.from_string "key=\"\\r\"") "key");
         assert_equal
           (TString "\"")
           (Hashtbl.find (Toml.from_string "key=\"\\\"\"") "key");
         assert_equal
           (TString "\\")
           (Hashtbl.find (Toml.from_string "key=\"\\\\\"") "key");
         assert_equal
           (TString "\\")
           (Hashtbl.find (Toml.from_string "key=\"\\\\\"") "key");
         assert_raises
           (Failure "Forbidden escaped char")
           (fun () -> Toml.from_string "key=\"\\j\"");
         assert_raises
           (Failure "Unterminated string")
           (fun () -> Toml.from_string "key=\"This string is not termin"));

      "Array key" >:: (fun () ->
        let str = "key = [true, true, false, true]" in
        let toml = Toml.from_string str in
        let var = Hashtbl.find toml "key" in
        assert_equal (TArray(NodeBool([true; true; false; true]))) var;
        let str = "key = []" in
        let toml = Toml.from_string str in
        let var = Hashtbl.find toml "key" in
        assert_equal (TArray(NodeEmpty)) var;
        let str = "key = [true, true,]" in
        let toml = Toml.from_string str in
        let var = Hashtbl.find toml "key" in
        assert_equal (TArray(NodeBool([true; true]))) var);

        "Nested Arrays" >:: (fun () ->
        let str ="key=[ [1,2],[\"a\",\"b\",\"c\",\"d\"]\n,[] ]" in
        let toml = Toml.from_string str in
        assert_equal
          (TArray(NodeArray([NodeInt([1; 2]);
                             NodeString(["a";"b";"c";"d"]);
                             NodeEmpty])))
          (Hashtbl.find toml "key"));
    
      "Grouped key" >:: (fun () ->
        let str = "[group1]\nkey = true\nkey2 = 1337" in
        let toml = Toml.from_string str in
        assert_raises Not_found (fun () -> Hashtbl.find toml "key");
        let group1 = get_table toml "group1" in
        assert_equal (TBool true) (Hashtbl.find group1 "key");
        assert_equal (TInt 1337) (Hashtbl.find group1 "key2"));

      "Comment" >:: (fun () ->
        let str = "[group1]\nkey = true # this is comment" in
        let toml = Toml.from_string str in
        let group1 = get_table toml "group1" in
        assert_equal (TBool true) (Hashtbl.find group1 "key"));

      "Date" >:: (fun () ->
        let str = "[group1]\nkey = 1979-05-27T07:32:00Z" in
        let toml = Toml.from_string str in
        let group1 = get_table toml "group1" in
         assert_equal
           (TDate {Unix.tm_year=79;Unix.tm_mon=04;Unix.tm_mday=27;
                   Unix.tm_hour=07;Unix.tm_min=32;Unix.tm_sec=0;
                   Unix.tm_wday=(-1);Unix.tm_yday=(-1);
                   Unix.tm_isdst=true;})
           (Hashtbl.find group1 "key"));

      "Same key, different group" >:: (fun () ->
        let str = "key=1[group]\nkey = 2" in
        let toml = Toml.from_string str in
        assert_equal
          (TInt 1)
          (Hashtbl.find toml "key");
        assert_equal
          (TInt 2)
          (Hashtbl.find (get_table toml "group") "key"));

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
