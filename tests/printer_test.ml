open OUnit
module Toml_key = Toml.Table.Key

let print_str str = str

let assert_equal_str x y = assert_equal ~printer:print_str x y

let create_table key_values =
    let table = Toml.Table.empty in
    List.fold_left (fun tbl (key, value) ->
      Toml.Table.add (Toml_key.of_string key) value tbl)
    table key_values

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

let toml_table key_values =
    create_table key_values |> string_of_table

let test = "Printing values" >:::
  [
    "simple string" >:: (fun () ->
      assert_equal_str
        "\"string value\""
        (string_of_value (Toml.Value.Of.string "string value")));
    "string with control chars" >:: (fun () ->
      assert_equal_str
        "\"str\\\\ing\\t\\n\\u0002\\\"\""
        (string_of_value (Toml.Value.Of.string "str\\ing\t\n\002\"")));
    "string with accented chars" >:: (fun () ->
      assert_equal_str
        "\"\195\169\""
        (string_of_value (Toml.Value.Of.string "\195\169")));

    "boolean true" >:: (fun () ->
      assert_equal_str
        "true"
        (string_of_value (Toml.Value.Of.bool true)));
    "boolean false" >:: (fun () ->
      assert_equal_str
        "false"
        (string_of_value (Toml.Value.Of.bool false)));

    "positive int" >:: (fun () ->
      assert_equal_str
        "42"
        (string_of_value (Toml.Value.Of.int 42)));
    "negative int" >:: (fun () ->
      assert_equal_str
        "-42"
        (string_of_value (Toml.Value.Of.int (-42))));

    "positive float" >:: (fun () ->
      assert_equal_str
        "42.24"
        (string_of_value (Toml.Value.Of.float 42.24)));
    "negative float" >:: (fun () ->
      assert_equal_str
        "-42.24"
        (string_of_value (Toml.Value.Of.float (-42.24))));
    "round float" >:: (fun () ->
      assert_equal_str
        "1.0"
        (string_of_value (Toml.Value.Of.float (1.))));
    "negative round float" >:: (fun () ->
      assert_equal_str
        "-1.0"
        (string_of_value (Toml.Value.Of.float (-1.))));

    "date" >:: (fun () ->
      let open UnixLabels
      in
      assert_equal_str
        "1979-05-27T07:32:00Z"
        (string_of_value (Toml.Value.Of.date (gmtime 296638320.))));

    "array value" >:: (fun () ->
      assert_equal_str
        "[4, 5]"
        (string_of_value (Toml.Value.Of.array (Toml.Value.Of.Array.int [4; 5]))));

    "table value" >:: (fun () ->
      assert_equal_str
        ((String.concat "\n" [
          "[dog]";
          "type = \"golden retriever\""])^"\n")
      (toml_table ["dog", (
        Toml.Value.Of.table (create_table ["type", (Toml.Value.Of.string "golden retriever")]))]));

    "table" >:: (fun () ->
      assert_equal_str
        ((String.concat "\n" [
          "[dog]";
          "type = \"golden retriever\""])^"\n")
      (toml_table ["dog", (
        Toml.Value.Of.table (create_table ["type", (Toml.Value.Of.string "golden retriever")]))]));

    "nested tables" >:: (fun () ->
      assert_equal_str
        ((String.concat "\n" [
          "[dog.tater]";
          "type = \"pug\""])^"\n")
      (toml_table ["dog", (
        Toml.Value.Of.table (create_table ["tater", (
          Toml.Value.Of.table (create_table ["type", (Toml.Value.Of.string "pug")]))]))]) );

    "table of empty array of tables" >:: (fun () ->
      assert_equal_str
        ("")
      (toml_table ["dog", (
        [] |> Toml.Value.Of.Array.table |> Toml.Value.Of.array)]));
    "table of array of tables" >:: (fun () ->
      assert_equal_str
        ((String.concat "\n" [
          "[[dog]]";
          "[dog.tater]";
          "type = \"pug\""])^"\n")
      (toml_table ["dog", (
        [
          create_table ["tater", (
            Toml.Value.Of.table (create_table ["type", (Toml.Value.Of.string "pug")]))]
      ] |> Toml.Value.Of.Array.table |> Toml.Value.Of.array)]));
    "table of nested array of tables" >:: (fun () ->
      assert_equal_str
        ((String.concat "\n" [
          "[[dog]]";
          "[dog.tater]";
          "type = \"pug\"";
          "[[dog.dalmatian]]";
          "number = 1";
          "[[dog.dalmatian]]";
          "number = 2";
        ])^"\n")
      (toml_table ["dog", (
        [
          create_table ["tater", (
            Toml.Value.Of.table (create_table ["type", (Toml.Value.Of.string "pug")]))];

          create_table ["dalmatian", [
            create_table ["number", Toml.Value.Of.int 1];
            create_table ["number", Toml.Value.Of.int 2];
          ]
          |> Toml.Value.Of.Array.table |> Toml.Value.Of.array ]
        ] |> Toml.Value.Of.Array.table |> Toml.Value.Of.array)]));

    "empty array" >:: (fun () ->
      assert_equal_str
        "[]"
        (string_of_array (Toml.Value.Of.Array.bool [])));
    "empty bool array" >:: (fun () ->
      assert_equal_str
        "[]"
        (string_of_array (Toml.Value.Of.Array.bool [])));
    "bool array" >:: (fun () ->
      assert_equal_str
        "[true, false]"
        (string_of_array (Toml.Value.Of.Array.bool [true; false])));
    "empty int array" >:: (fun () ->
      assert_equal_str
        "[]"
        (string_of_array (Toml.Value.Of.Array.int [])));
    "int array" >:: (fun () ->
      assert_equal_str
        "[4, 5]"
        (string_of_array (Toml.Value.Of.Array.int [4; 5])));
    "empty float array" >:: (fun () ->
      assert_equal_str
        "[]"
        (string_of_array (Toml.Value.Of.Array.float [])));
    "float array" >:: (fun () ->
      assert_equal_str
        "[4.2, 3.14]"
        (string_of_array (Toml.Value.Of.Array.float [4.2; 3.14])));
    "empty string array" >:: (fun () ->
      assert_equal_str
        "[]"
        (string_of_array (Toml.Value.Of.Array.string [])));
    "string array" >:: (fun () ->
      assert_equal_str
        "[\"a\", \"b\"]"
        (string_of_array (Toml.Value.Of.Array.string ["a";"b"])));
    "empty date array" >:: (fun () ->
      assert_equal_str
        "[]"
        (string_of_array (Toml.Value.Of.Array.date [])));
    "date array" >:: (fun () ->
      let open UnixLabels
      in
      assert_equal_str
        "[1979-05-27T07:32:00Z, 1979-05-27T08:38:40Z]"
        (string_of_array (Toml.Value.Of.Array.date [
          (gmtime 296638320.);(gmtime 296642320.)])));
    "empty array of arrays" >:: (fun () ->
      assert_equal_str
        "[]"
        (string_of_array (Toml.Value.Of.Array.array [])));
    "array of arrays" >:: (fun () ->
      assert_equal_str
        "[[2341, 2242], [[true]]]"
        (string_of_array (Toml.Value.Of.Array.array [
          (Toml.Value.Of.Array.int [2341;2242]);
          (Toml.Value.Of.Array.array [Toml.Value.Of.Array.bool [true]])])));
    "empty array of tables" >:: (fun () ->
      assert_raises
        (Failure "Cannot format array of tables, use Toml.Printer.table")
        (fun () -> ignore(string_of_array ([] |> Toml.Value.Of.Array.table)))
    );
    "array of tables" >:: (fun () ->
      assert_raises
        (Failure "Cannot format array of tables, use Toml.Printer.table")
        (fun () -> ignore(string_of_array ([
            create_table ["number", Toml.Value.Of.int 1];
            create_table ["number", Toml.Value.Of.int 2];
          ]
          |> Toml.Value.Of.Array.table)))
    );
    "mixed example" >:: (fun () ->
      let level3_table =
          Toml.Table.empty
          |> Toml.Table.add (Toml_key.of_string "is_deep") (Toml.Value.Of.bool true)
          |> Toml.Table.add (Toml_key.of_string "location") (Toml.Value.Of.string "basement")
      in

      let level2_1_table = create_table ["level3", (Toml.Value.Of.table level3_table)] in
      let level2_2_table = create_table ["is_less_deep", (Toml.Value.Of.bool true)] in

      let level1_table =
          Toml.Table.empty
          |> Toml.Table.add (Toml_key.of_string "level2_1") (Toml.Value.Of.table level2_1_table)
          |> Toml.Table.add (Toml_key.of_string "level2_2") (Toml.Value.Of.table level2_2_table)
      in

      let top_level_table =
          Toml.Table.empty
          |> Toml.Table.add (Toml_key.of_string "toplevel") (Toml.Value.Of.string "ocaml")
          |> Toml.Table.add (Toml_key.of_string "level1") (Toml.Value.Of.table level1_table)
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
