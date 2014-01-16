(**
  * Here is the main file of testing
  *)

open OUnit
open TypeTo
open Pprint

let _ =
  let assert_equal = assert_equal ~printer:string_of_toml in
  let suite = "Main tests" >:::
  [
    "Rache Methodology Approved" >::: [
       "simple key value" >:: (fun () ->
        let str = "key = \"VaLUe42\"" in
        let toml = To.parse str in
        let var = Hashtbl.find toml "key" in
        assert_equal var (TString"VaLUe42");
        assert_bool "Bad grammar" (var <> TString("value42")));

      "Two keys value" >:: (fun () ->
        let str = "key = \"VaLUe42\"\nkey2=42" in
        let toml = To.parse str in
        let var = Hashtbl.find toml "key" and var2 = Hashtbl.find toml "key2" in
        assert_equal var (TString "VaLUe42");
        assert_equal var2 (TInt 42));

      "Float key" >:: (fun () ->
        let str = "key = 3.141595" in
        let toml = To.parse str in
        let var = Hashtbl.find toml "key" in
        assert_equal var (TFloat 3.141595));

      "Bool key" >:: (fun () ->
        let str = "key = true" in
        let toml = To.parse str in
        let var = Hashtbl.find toml "key" in
        assert_equal var (TBool true));

      "String" >:: (fun () ->
         assert_equal
           (TString "\b")
           (Hashtbl.find (To.parse "key=\"\\b\"") "key");
         assert_equal
           (TString "\t")
           (Hashtbl.find (To.parse "key=\"\\t\"") "key");
         assert_equal
           (TString "\n")
           (Hashtbl.find (To.parse "key=\"\\n\"") "key");
         assert_equal
           (TString "\r")
           (Hashtbl.find (To.parse "key=\"\\r\"") "key");
         assert_equal
           (TString "\"")
           (Hashtbl.find (To.parse "key=\"\\\"\"") "key");
         assert_equal
           (TString "\\")
           (Hashtbl.find (To.parse "key=\"\\\\\"") "key");
         assert_equal
           (TString "\\")
           (Hashtbl.find (To.parse "key=\"\\\\\"") "key");
         assert_raises
           (Failure "Forbidden escaped char")
           (fun () -> To.parse "key=\"\\j\""));

      "Array key" >:: (fun () ->
        let str = "key = [true, true, false, true]" in
        let toml = To.parse str in
        let var = Hashtbl.find toml "key" in
        assert_equal var (TArray(NodeBool([true; true; false; true])));
        let str = "key = [true, true,]" in
        let toml = To.parse str in
        let var = Hashtbl.find toml "key" in
        assert_equal var (TArray(NodeBool([true; true]))));

      "Nested Arrays" >:: (fun () ->
        let str ="key=[[1,2],[\"a\",\"b\",\"c\",\"d\"]]" in
        let toml = To.parse str in
        assert_equal
          (TArray(NodeArray([NodeInt([1; 2]);
                             NodeString(["a";"b";"c";"d"])])))
          (Hashtbl.find toml "key"));
    
      "Grouped key" >:: (fun () ->
        let str = "[group1]\nkey = true\nkey2 = 1337" in
        let toml = To.parse str in
        let var = Hashtbl.find toml "group1.key" in
        assert_equal var (TBool true);
        assert_raises Not_found (fun () -> Hashtbl.find toml "key");
        assert_equal (TInt 1337) (Hashtbl.find toml "group1.key2"));

      "Comment" >:: (fun () ->
        let str = "[group1]\nkey = true # this is comment" in
        let toml = To.parse str in
        let var = Hashtbl.find toml "group1.key" in
        assert_equal var (TBool true));

      "Date" >:: (fun () ->
        let str = "[group1]\nkey = 1979-05-27T07:32:00Z" in
        let toml = To.parse str in
        let var = Hashtbl.find toml "group1.key" in
         assert_equal (TDate "1979-05-27T07:32:00Z") var);

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
