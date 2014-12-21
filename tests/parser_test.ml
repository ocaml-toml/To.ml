(**
  * Here is the main file of testing
  *)

open OUnit
open Toml
module Toml_key = Toml.Table.Key

let table_find key_string = Table.find (Toml_key.of_string key_string)

let get_table tbl key =
  try
    table_find key tbl |> Toml.Value.To.table
  with exn ->
    assert false

let mk_raw_table x =
  List.fold_left (fun tbl (k,v) ->
    Table.add (Toml_key.of_string k) v tbl)
  Table.empty x

open Toml.Parser

let _ =
  let assert_equal = OUnit.assert_equal in
  let suite = "Main tests" >:::
  [
    "Rache Methodology Approved" >::: [
       "simple key value" >:: (fun () ->
        let str = "key = \"VaLUe42\"" in
        let toml = Parser.from_string str in
        let var = table_find "key" toml in
        assert_equal (Toml.Value.Of.string "VaLUe42") var;
        assert_bool "Bad grammar" (var <> (Toml.Value.Of.string "value42")));

      "Two keys value" >:: (fun () ->
        let str = "key = \"VaLUe42\"\nkey2=42" in
        let toml = Parser.from_string str in
        let var = table_find "key" toml and var2 = table_find "key2" toml in
        assert_equal (Toml.Value.Of.string "VaLUe42") var;
        assert_equal (Toml.Value.Of.int 42) var2);

      "Int" >:: (fun () ->
        let str = "key = 42\nkey2=-42" in
        let toml = Parser.from_string str in
        assert_equal (Toml.Value.Of.int 42) (table_find "key" toml);
        assert_equal (Toml.Value.Of.int (-42)) (table_find "key2" toml));

      "Float key" >:: (fun () ->
        let str = "key = 3.141595\nkey2=-3.141595" in
        let toml = Parser.from_string str in
        assert_equal (Toml.Value.Of.float 3.141595) (table_find "key" toml);
        assert_equal (Toml.Value.Of.float (-3.141595)) (table_find "key2" toml));

      "Bool key" >:: (fun () ->
        let str = "key = true\nkey2=false" in
        let toml = Parser.from_string str in
        assert_equal (Toml.Value.Of.bool true) (table_find "key" toml);
        assert_equal (Toml.Value.Of.bool false) (table_find "key2" toml));

      "String" >:: (fun () ->
         assert_equal
           (Toml.Value.Of.string "\b")
           (table_find "key" (Parser.from_string "key=\"\\b\""));
         assert_equal
           (Toml.Value.Of.string "\t")
           (table_find "key" (Parser.from_string "key=\"\\t\""));
         assert_equal
           (Toml.Value.Of.string "\n")
           (table_find "key" (Parser.from_string "key=\"\\n\""));
         assert_equal
           (Toml.Value.Of.string "\r")
           (table_find "key" (Parser.from_string "key=\"\\r\""));
         assert_equal
           (Toml.Value.Of.string "\"")
           (table_find "key" (Parser.from_string "key=\"\\\"\""));
         assert_equal
           (Toml.Value.Of.string "\\")
           (table_find "key" (Parser.from_string "key=\"\\\\\""));
         assert_equal
           (Toml.Value.Of.string "\\")
           (table_find "key" (Parser.from_string "key=\"\\\\\""));
         assert_raises (Parser.Error (
           "Error in <string> at line 1 at column 6 (position 6): " ^
           "Forbidden escaped char",
           {source = "<string>"; line = 1; column = 6; position = 6}))
           (fun () -> Parser.from_string "key=\"\\j\"");
         assert_raises (Parser.Error(
           "Error in <string> at line 1 at column 30 (position 30): " ^
           "Unterminated string",
           {source = "<string>"; line = 1; column = 30; position = 30}))
           (fun () -> Parser.from_string "key=\"This string is not termin"));

      "Array key" >:: (fun () ->
        let str = "key = [true, true, false, true]" in
        let toml = Parser.from_string str in
        let var = table_find "key" toml in
        assert_equal (
          Toml.Value.Of.Array.bool [true; true; false; true] |> Toml.Value.Of.array) var;
        let str = "key = []" in
        let toml = Parser.from_string str in
        let var = table_find "key" toml in
        assert_equal (Toml.Value.Of.Array.bool [] |> Toml.Value.Of.array) var;
        let str = "key = [true, true,]" in
        let toml = Parser.from_string str in
        let var = table_find "key" toml in
        assert_equal (
          Toml.Value.Of.Array.bool [true; true] |> Toml.Value.Of.array) var);

        "Nested Arrays" >:: (fun () ->
        let str ="key=[ [1,2],[\"a\",\"b\",\"c\",\"d\"]\n,[] ]" in
        let toml = Parser.from_string str in
        assert_equal
          ([Toml.Value.Of.Array.int [1; 2];
            Toml.Value.Of.Array.string ["a";"b";"c";"d"];
            Toml.Value.Of.Array.bool []]
            |> Toml.Value.Of.Array.array
            |> Toml.Value.Of.array)
          (table_find "key" toml));

      "Grouped key" >:: (fun () ->
        let str = "[group1]\nkey = true\nkey2 = 1337" in
        let toml = Parser.from_string str in
        assert_raises Not_found (fun () -> table_find "key" toml);
        let group1 = get_table toml "group1" in
        assert_equal (Toml.Value.Of.bool true) (table_find "key" group1);
        assert_equal (Toml.Value.Of.int 1337) (table_find "key2" group1));

      "Comment" >:: (fun () ->
        let str = "[group1]\nkey = true # this is comment" in
        let toml = Parser.from_string str in
        let group1 = get_table toml "group1" in
        assert_equal (Toml.Value.Of.bool true) (table_find "key" group1));

      "Date" >:: (fun () ->
        let str = "[group1]\nkey = 1979-05-27T07:32:00Z" in
        let toml = Parser.from_string str in
        let group1 = get_table toml "group1" in
         assert_equal
           (Toml.Value.Of.date {Unix.tm_year=79;Unix.tm_mon=04;Unix.tm_mday=27;
                   Unix.tm_hour=07;Unix.tm_min=32;Unix.tm_sec=0;
                   Unix.tm_wday=(-1);Unix.tm_yday=(-1);
                   Unix.tm_isdst=true;})
           (table_find "key" group1));

      "Array of tables" >:: (fun () ->
        let str = [
            "[[a.b.c]]";
            "field1 = 1";
            "field2 = 2";

            "[[a.b.c]]";
            "field1 = 10";
            "field2 = 20";
          ] |> String.concat "\n"
        in
        let toml = Parser.from_string str in
        let c = Toml.Value.Of.Array.table [
          mk_raw_table [
            "field1", Toml.Value.Of.int 1;
            "field2", Toml.Value.Of.int 2;
          ];
          mk_raw_table [
            "field1", Toml.Value.Of.int 10;
            "field2", Toml.Value.Of.int 20;
          ];
          ] |> Toml.Value.Of.array
        in
        let b = Toml.Table.empty |> Toml.Table.add (Toml.key "c") c |> Toml.Value.Of.table in
        let a = Toml.Table.empty |> Toml.Table.add (Toml.key "b") b |> Toml.Value.Of.table in
        let expected = Toml.Table.empty |> Toml.Table.add (Toml.key "a") a in
        assert_equal expected toml;
      );
      "Nested array of tables, official example" >:: (fun () ->
        let str = [
          "[[fruit]]";
          "  name = \"apple\"";
          "  [fruit.physical]";
          "    color = \"red\"";
          "    shape = \"round\"";
          "  [[fruit.variety]]";
          "    name = \"red delicious\"";
          "  [[fruit.variety]]";
          "    name = \"granny smith\"";
          "[[fruit]]";
          "  name = \"banana\"";
          "  [[fruit.variety]]";
          "  name = \"plantain\"";
        ] |> String.concat "\n"
        in
        let toml = Parser.from_string str in

        let test = Toml.Table.find (Toml.key "fruit") toml |>
        Toml.Value.To.array |> Toml.Value.To.Array.table
        |>List.hd|>Toml.Table.find (Toml.key
        "variety")|>Toml.Value.To.array|>Toml.Value.To.Array.table|>List.rev|>List.hd|>Toml.Table.find
        (Toml.key "name")|>Toml.Value.To.string in

        assert_equal 1 (Toml.Table.cardinal toml);
        assert_equal true (Toml.Table.mem (Toml.key "fruit") toml);
        let fruits = Toml.Table.find (Toml.key "fruit") toml
          |> Toml.Value.To.array |> Toml.Value.To.Array.table
        in
        assert_equal 2 (List.length fruits);
        let apple = List.hd fruits in
        assert_equal 3 (Toml.Table.cardinal apple);
        assert_equal "apple" (
          Toml.Table.find (Toml.key "name") apple |> Toml.Value.To.string);
        let physical =
          Toml.Table.find (Toml.key "physical") apple |> Toml.Value.To.table in
        let expected_physical = mk_raw_table [
          "color", Toml.Value.Of.string "red";
          "shape", Toml.Value.Of.string "round";
        ] in
        assert_equal expected_physical physical;
        let apple_varieties =
          Toml.Table.find (Toml.key "variety") apple
          |> Toml.Value.To.array |> Toml.Value.To.Array.table
        in
        assert_equal 2 (List.length apple_varieties);
        let expected_red_delicious = mk_raw_table [
          "name", Toml.Value.Of.string "red delicious";
        ] in
        assert_equal expected_red_delicious (List.hd apple_varieties);
        let expected_granny_smith = mk_raw_table [
          "name", Toml.Value.Of.string "granny smith";
        ] in
        assert_equal expected_granny_smith (List.rev apple_varieties |> List.hd);
        let banana = List.rev fruits |> List.hd in
        assert_equal 2 (Toml.Table.cardinal banana);
        assert_equal "banana" (
          Toml.Table.find (Toml.key "name") banana |> Toml.Value.To.string);
        let banana_varieties =
          Toml.Table.find (Toml.key "variety") banana
          |> Toml.Value.To.array |> Toml.Value.To.Array.table
        in
        assert_equal 1 (List.length banana_varieties);
        let expected_plantain = mk_raw_table [
          "name", Toml.Value.Of.string "plantain";
        ] in
        assert_equal expected_plantain (List.hd banana_varieties);
      );
      "Array of tables expected, got table" >:: (fun () ->
        let str = [
            "[a.b.c]";
            "field1 = 1";
            "field2 = 2";

            "[[a.b.c]]";
            "field1 = 10";
            "field2 = 20";
          ] |> String.concat "\n"
        in
        assert_raises
          (Parser.Error (
            "Error in <string> at line 6 at column 11 (position 63): c is a table, not an array of tables",
            { source = "<string>"; line = 6; column = 11; position = 63; }))
          (fun () -> ignore(Parser.from_string str));
      );
      "Nested array of table, initially empty" >:: (fun () ->
        let str = [
          "[[fruit]]";
          "[vegetable]";
          "name=\"lettuce\"";
          "[[fruit]]";
          "name=\"apple\"";
        ] |> String.concat "\n" in
        let toml = Parser.from_string str in
        assert_equal 2 (Toml.Table.cardinal toml);
        let expected_vegetable = mk_raw_table [
          "name", Toml.Value.Of.string "lettuce";
        ] in
        let vegetable =
          Toml.Table.find (Toml.key "vegetable") toml
          |> Toml.Value.To.table
        in
        assert_equal expected_vegetable vegetable;
        let fruits =
          Toml.Table.find (Toml.key "fruit") toml
          |> Toml.Value.To.array
          |> Toml.Value.To.Array.table
        in
        assert_equal 1 (List.length fruits);
        let expected_fruit = mk_raw_table [
          "name", Toml.Value.Of.string "apple";
        ] in
        assert_equal expected_fruit (List.hd fruits);
      );
      "Same key, different group" >:: (fun () ->
        let str = "key=1[group]\nkey = 2" in
        let toml = Parser.from_string str in
        assert_equal
          (Toml.Value.Of.int 1)
          (table_find "key" toml);
        assert_equal
          (Toml.Value.Of.int 2)
          (table_find "key" (get_table toml "group")));

      "Unicode" >:: (fun () ->
        let str = "key=\"\\u03C9\"\nkey2=\"\\u4E2D\\u56FD\\u0021\"" in
        let toml = Parser.from_string str in
        assert_equal
          (Toml.Value.Of.string "ω")
          (table_find "key" toml);
        assert_equal
          (Toml.Value.Of.string "中国!")
          (table_find "key2" toml));

      "Error location when endlines in strings" >:: (fun () ->
        let str =
          "\na = [\"b\"]\nb = \"error here\n\nc = \"should not be reached\""
        in
        assert_raises
          (Parser.Error (
            "Error in <string> at line 5 at column 15 (position 43)",
            { source = "<string>"; line = 5; column = 15; position = 43; }))
          (fun () -> ignore(Parser.from_string str));
        );

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
