open OUnit
open TomlInternal.Type

let print_str str = str

let assert_equal_str x y = assert_equal ~printer:print_str x y

let create_table key value =
    let table = Toml.Table.empty in
    Toml.Table.add key value table

let string_of_table toml_table =
    let buffer = Buffer.create 100 in
    let formatter = Format.formatter_of_buffer buffer in
    toml_table |> Toml.Printer.table formatter;
    Buffer.contents buffer

let string_of_value toml_value =
    let buffer = Buffer.create 100 in
    let formatter = Format.formatter_of_buffer buffer in
    toml_value |> Toml.Printer.value formatter;
    Buffer.contents buffer

let string_of_array toml_array =
    let buffer = Buffer.create 100 in
    let formatter = Format.formatter_of_buffer buffer in
    toml_array |> Toml.Printer.array formatter;
    Buffer.contents buffer

let toml_table key value =
    create_table key value |> string_of_table

let test = "Printing values" >:::
  [
    "simple string" >:: (fun () ->
      assert_equal_str
        "\"string value\""
        (string_of_value (TString "string value")));
    "string with control chars" >:: (fun () ->
      assert_equal_str
        "\"str\\\\ing\\t\\n\\u0002\\\"\""
        (string_of_value (TString "str\\ing\t\n\002\"")));
    "string with accented chars" >:: (fun () ->
      assert_equal_str
        "\"\195\169\""
        (string_of_value (TString "\195\169")));

    "boolean true" >:: (fun () ->
      assert_equal_str
        "true"
        (string_of_value (TBool true)));
    "boolean false" >:: (fun () ->
      assert_equal_str
        "false"
        (string_of_value (TBool false)));

    "positive int" >:: (fun () ->
      assert_equal_str
        "42"
        (string_of_value (TInt 42)));
    "negative int" >:: (fun () ->
      assert_equal_str
        "-42"
        (string_of_value (TInt (-42))));

    "positive float" >:: (fun () ->
      assert_equal_str
        "42.24"
        (string_of_value (TFloat 42.24)));
    "negative float" >:: (fun () ->
      assert_equal_str
        "-42.24"
        (string_of_value (TFloat (-42.24))));

    "date" >:: (fun () ->
      let open UnixLabels
      in
      assert_equal_str
        "1979-05-27T07:32:00Z"
        (string_of_value (TDate (gmtime 296638320.))));

    "array value" >:: (fun () ->
      assert_equal_str
        "[4, 5]"
        (string_of_value (TArray (NodeInt [4; 5]))));

    "table value" >:: (fun () ->
      assert_equal_str
        ((String.concat "\n" [
          "[dog]";
          "type = \"golden retriever\""])^"\n")
      (toml_table "dog" (
        TTable (create_table "type" (TString "golden retriever")))));

    "table" >:: (fun () ->
      assert_equal_str
        ((String.concat "\n" [
          "[dog]";
          "type = \"golden retriever\""])^"\n")
      (toml_table "dog" (
        TTable (create_table "type" (TString "golden retriever")))));

    "nested tables" >:: (fun () ->
      assert_equal_str
        ((String.concat "\n" [
          "[dog.tater]";
          "type = \"pug\""])^"\n")
      (toml_table "dog" (
        TTable (create_table "tater" (
          TTable (create_table "type" (TString "pug")))))) );

    "empty array" >:: (fun () ->
      assert_equal_str
        "[]"
        (string_of_array NodeEmpty));
    "empty bool array" >:: (fun () ->
      assert_equal_str
        "[]"
        (string_of_array (NodeBool [])));
    "bool array" >:: (fun () ->
      assert_equal_str
        "[true, false]"
        (string_of_array (NodeBool [true; false])));
    "empty int array" >:: (fun () ->
      assert_equal_str
        "[]"
        (string_of_array (NodeInt [])));
    "int array" >:: (fun () ->
      assert_equal_str
        "[4, 5]"
        (string_of_array (NodeInt [4; 5])));
    "empty float array" >:: (fun () ->
      assert_equal_str
        "[]"
        (string_of_array (NodeFloat [])));
    "float array" >:: (fun () ->
      assert_equal_str
        "[4.2, 3.14]"
        (string_of_array (NodeFloat [4.2; 3.14])));
    "empty string array" >:: (fun () ->
      assert_equal_str
        "[]"
        (string_of_array (NodeString [])));
    "string array" >:: (fun () ->
      assert_equal_str
        "[\"a\", \"b\"]"
        (string_of_array (NodeString ["a";"b"])));
    "empty date array" >:: (fun () ->
      assert_equal_str
        "[]"
        (string_of_array (NodeDate [])));
    "date array" >:: (fun () ->
      let open UnixLabels
      in
      assert_equal_str
        "[1979-05-27T07:32:00Z, 1979-05-27T08:38:40Z]"
        (string_of_array (NodeDate [
          (gmtime 296638320.);(gmtime 296642320.)])));
    "empty array of arrays" >:: (fun () ->
      assert_equal_str
        "[]"
        (string_of_array (NodeArray [])));
    "array of arrays" >:: (fun () ->
      assert_equal_str
        "[[2341, 2242], [[true]]]"
        (string_of_array (NodeArray [
          (NodeInt [2341;2242]);
          (NodeArray [NodeBool [true]])])));

    "mixed example" >:: (fun () ->
      let level3_table =
          Toml.Table.empty
          |> Toml.Table.add "is_deep" (TBool true)
          |> Toml.Table.add "location" (TString "basement")
      in

      let level2_1_table = create_table "level3" (TTable level3_table) in
      let level2_2_table = create_table "is_less_deep" (TBool true) in

      let level1_table =
          Toml.Table.empty
          |> Toml.Table.add "level2_1" (TTable level2_1_table)
          |> Toml.Table.add "level2_2" (TTable level2_2_table)
      in

      let top_level_table =
          Toml.Table.empty
          |> Toml.Table.add "toplevel" (TString "ocaml")
          |> Toml.Table.add "level1" (TTable level1_table)
      in

      assert_equal_str
        ((String.concat "\n" [
          "toplevel = \"ocaml\"";
          "[level1.level2_1.level3]";
          "is_deep = true";
          "location = \"basement\"";
          "[level1.level2_2]";
          "is_less_deep = true";
        ])^"\n")
        (top_level_table |> string_of_table));

  ]

let _ = OUnit.run_test_tt_main test
