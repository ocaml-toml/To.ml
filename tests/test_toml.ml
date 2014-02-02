(**
  * Here is the main file of testing
  * FIXME: printer is broken
  *)

open OUnit
open TypeTo
(* open Pprint *)

let _ =
  let assert_equal = OUnit.assert_equal (*~printer:string_of_entrie*) in
  let suite = "Main tests" >:::
  [
    "Rache Methodology Approved" >::: [
       "simple key value" >:: (fun () ->
        let str = "key = \"VaLUe42\"" in
        let toml = To.parse str in
        let var = get_value toml "key" in
        assert_equal (TString"VaLUe42") var;
        assert_bool "Bad grammar" (var <> (TString("value42"))));

      "Two keys value" >:: (fun () ->
        let str = "key = \"VaLUe42\"\nkey2=42" in
        let toml = To.parse str in
        let var = get_value toml "key" and var2 = get_value toml "key2" in
        assert_equal (TString "VaLUe42") var;
        assert_equal (TInt 42) var2);

      "Int" >:: (fun () ->
        let str = "key = 42\nkey2=-42" in
        let toml = To.parse str in
        assert_equal (TInt 42) (get_value toml "key");
        assert_equal (TInt (-42)) (get_value toml "key2"));

      "Float key" >:: (fun () ->
        let str = "key = 3.141595\nkey2=-3.141595" in
        let toml = To.parse str in
        assert_equal (TFloat 3.141595) (get_value toml "key");
        assert_equal (TFloat (-3.141595)) (get_value toml "key2"));

      "Bool key" >:: (fun () ->
        let str = "key = true\nkey2=false" in
        let toml = To.parse str in
        assert_equal (TBool true) (get_value toml "key");
        assert_equal (TBool false) (get_value toml "key2"));

      "String" >:: (fun () ->
         assert_equal
           (TString "\b")
           (get_value (To.parse "key=\"\\b\"") "key");
         assert_equal
           (TString "\t")
           (get_value (To.parse "key=\"\\t\"") "key");
         assert_equal
           (TString "\n")
           (get_value (To.parse "key=\"\\n\"") "key");
         assert_equal
           (TString "\r")
           (get_value (To.parse "key=\"\\r\"") "key");
         assert_equal
           (TString "\"")
           (get_value (To.parse "key=\"\\\"\"") "key");
         assert_equal
           (TString "\\")
           (get_value (To.parse "key=\"\\\\\"") "key");
         assert_equal
           (TString "\\")
           (get_value (To.parse "key=\"\\\\\"") "key");
         assert_raises
           (Failure "Forbidden escaped char")
           (fun () -> To.parse "key=\"\\j\""));

      "Array key" >:: (fun () ->
        let str = "key = [true, true, false, true]" in
        let toml = To.parse str in
        let var = get_value toml "key" in
        assert_equal (TArray(NodeBool([true; true; false; true]))) var;
        let str = "key = [true, true,]" in
        let toml = To.parse str in
        let var = get_value toml "key" in
        assert_equal (TArray(NodeBool([true; true]))) var);

      "Nested Arrays" >:: (fun () ->
        let str ="key=[[1,2],[\"a\",\"b\",\"c\",\"d\"]]" in
        let toml = To.parse str in
        assert_equal
          (TArray(NodeArray([NodeInt([1; 2]);
                             NodeString(["a";"b";"c";"d"])])))
          (get_value toml "key"));
    
      "Grouped key" >:: (fun () ->
        let str = "[group1]\nkey = true\nkey2 = 1337" in
        let toml = To.parse str in
        assert_raises Not_found (fun () -> get_value toml "key");
        let group1 = get_table toml "group1" in
        assert_equal (TBool true) (get_value group1 "key");
        assert_equal (TInt 1337) (get_value group1 "key2"));

      "Comment" >:: (fun () ->
        let str = "[group1]\nkey = true # this is comment" in
        let toml = To.parse str in
        let group1 = get_table toml "group1" in
        assert_equal (TBool true) (get_value group1 "key"));

      "Date" >:: (fun () ->
        let str = "[group1]\nkey = 1979-05-27T07:32:00Z" in
        let toml = To.parse str in
        let group1 = get_table toml "group1" in
         assert_equal
           (TDate "1979-05-27T07:32:00Z") (get_value group1 "key"));

      "Same key, different group" >:: (fun () ->
        let str = "key=1[group]\nkey = 2" in
        let toml = To.parse str in
        assert_equal
          (TInt 1)
          (get_value toml "key");
        assert_equal
          (TInt 2)
          (get_value (get_table toml "group") "key"));

      "get_table/value failure" >:: (fun () ->
        let str = "key1=1[group1]\nkey2 = 1" in
        let toml = To.parse str in
        assert_raises
          (Failure "group1 is a table")
          (fun () -> get_value toml "group1");
        assert_raises
          (Failure "key1 is a value")
          (fun () -> get_table toml "key1"));

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
