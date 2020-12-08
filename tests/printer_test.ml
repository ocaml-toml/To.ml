open OUnit
open Toml.Types

let test fn expected testing () =
  assert_equal
    ~printer:(fun x -> x)
    expected
    (Toml.Printer.string_of_value (fn testing))

let test_string = test (fun v -> TString v)

let test_bool = test (fun v -> TBool v)

let test_int = test (fun v -> TInt v)

let test_float = test (fun v -> TFloat v)

let test_date = test (fun v -> TDate v)

let test_int_array = test (fun v -> TArray (NodeInt v))

let test_bool_array = test (fun v -> TArray (NodeBool v))

let test_float_array = test (fun v -> TArray (NodeFloat v))

let test_string_array = test (fun v -> TArray (NodeString v))

let test_date_array = test (fun v -> TArray (NodeDate v))

let test_array_array = test (fun v -> TArray (NodeArray v))

let test_table expected key_values () =
  assert_equal
    ~printer:(fun x -> x)
    (String.concat "\n" expected ^ "\n")
    (TTable (Toml.Min.of_key_values key_values) |> Toml.Printer.string_of_value)

let suite =
  "Printing simple"
  >::: [ "values string" >:: test_string "\"string value\"" "string value"
       ; "string with control chars"
         >:: test_string "'''\nstr\\ing\t\n\002\"'''" "str\\ing\t\n\002\""
       ; "string with accented chars" >:: test_string "\"\195\169\"" "\195\169"
       ; "boolean true" >:: test_bool "true" true
       ; "boolean false" >:: test_bool "false" false
       ; "positive int" >:: test_int "42" 42
       ; "negative int" >:: test_int "-42" (-42)
       ; "positive float" >:: test_float "42.24" 42.24
       ; "negative float" >:: test_float "-42.24" (-42.24)
       ; "round float" >:: test_float "1.0" 1.
       ; "negative round float" >:: test_float "-1.0" (-1.)
       ; "date (1)" >:: test_date "1979-05-27T07:32:00+00:00" 296638320.
       ; "date (2)" >:: test_date "1970-01-01T00:00:00+00:00" 0.
       ; "empty int array" >:: test_int_array "[]" []
       ; "int array" >:: test_int_array "[4, 5]" [ 4; 5 ]
       ; "empty bool array" >:: test_bool_array "[]" []
       ; "bool array" >:: test_bool_array "[true, false]" [ true; false ]
       ; "empty float array" >:: test_float_array "[]" []
       ; "float array" >:: test_float_array "[4.2, 3.14]" [ 4.2; 3.14 ]
       ; "empty string array" >:: test_string_array "[]" []
       ; "string array" >:: test_string_array "[\"a\", \"b\"]" [ "a"; "b" ]
       ; "empty date array" >:: test_date_array "[]" []
       ; "date array"
         >:: test_date_array
               "[1979-05-27T07:32:00+00:00, 1979-05-27T08:38:40+00:00]"
               [ 296638320.; 296642320. ]
       ; "table"
         >:: test_table
               [ "[dog]"; "type = \"golden retriever\"" ]
               [ ( Toml.Min.key "dog"
                 , TTable
                     (Toml.Min.of_key_values
                        [ (Toml.Min.key "type", TString "golden retriever") ])
                 )
               ]
       ; "nested tables"
         >:: test_table
               [ "[dog.tater]"; "type = \"pug\"" ]
               [ ( Toml.Min.key "dog"
                 , TTable
                     (Toml.Min.of_key_values
                        [ ( Toml.Min.key "tater"
                          , TTable
                              (Toml.Min.of_key_values
                                 [ (Toml.Min.key "type", TString "pug") ]) )
                        ]) )
               ]
       ; ( "table of empty array of tables" >:: fun () ->
           assert_equal
             ~printer:(fun x -> x)
             ""
             (Toml.Printer.string_of_table
                (Toml.Min.of_key_values
                   [ (Toml.Min.key "dog", TArray (NodeTable [])) ])) )
       ; "table of array of tables"
         >:: test_table
               [ "[[dog]]"; "[dog.tater]"; "type = \"pug\"" ]
               [ ( Toml.Min.key "dog"
                 , TArray
                     (NodeTable
                        [ Toml.Min.of_key_values
                            [ ( Toml.Min.key "tater"
                              , TTable
                                  (Toml.Min.of_key_values
                                     [ (Toml.Min.key "type", TString "pug") ])
                              )
                            ]
                        ]) )
               ]
       ; "table of nested array of tables"
         >:: test_table
               [ "[[dog]]"
               ; "[dog.tater]"
               ; "type = \"pug\""
               ; "[[dog.dalmatian]]"
               ; "number = 1"
               ; "[[dog.dalmatian]]"
               ; "number = 2"
               ]
               [ ( Toml.Min.key "dog"
                 , TArray
                     (NodeTable
                        [ Toml.Min.of_key_values
                            [ ( Toml.Min.key "tater"
                              , TTable
                                  (Toml.Min.of_key_values
                                     [ (Toml.Min.key "type", TString "pug") ])
                              )
                            ]
                        ; Toml.Min.of_key_values
                            [ ( Toml.Min.key "dalmatian"
                              , TArray
                                  (NodeTable
                                     [ Toml.Min.of_key_values
                                         [ (Toml.Min.key "number", TInt 1) ]
                                     ; Toml.Min.of_key_values
                                         [ (Toml.Min.key "number", TInt 2) ]
                                     ]) )
                            ]
                        ]) )
               ]
       ; "empty array of arrays" >:: test_array_array "[]" []
       ; "array of empty arrays" >:: test_array_array "[[]]" [ NodeInt [] ]
       ; "array of arrays"
         >:: test_array_array "[[2341, 2242], [true]]"
               [ NodeInt [ 2341; 2242 ]; NodeBool [ true ] ]
       ; ( "empty array of tables" >:: fun () ->
           assert_raises
             (Invalid_argument
                "Cannot format array of tables, use Toml.Printer.table")
             (fun () -> ignore (Toml.Printer.string_of_array (NodeTable []))) )
       ; ( "array of tables" >:: fun () ->
           assert_raises
             (Invalid_argument
                "Cannot format array of tables, use Toml.Printer.table")
             (fun () ->
               ignore
                 (Toml.Printer.string_of_array
                    (NodeTable
                       [ Toml.Min.of_key_values
                           [ (Toml.Min.key "number", TInt 1) ]
                       ; Toml.Min.of_key_values
                           [ (Toml.Min.key "number", TInt 2) ]
                       ]))) )
       ; ( "mixed example" >:: fun () ->
           let level3_table =
             Toml.Min.of_key_values
               [ (Toml.Min.key "is_deep", TBool true)
               ; (Toml.Min.key "location", TString "basement")
               ]
           in

           let level2_1_table =
             Toml.Min.of_key_values
               [ (Toml.Min.key "level3", TTable level3_table) ]
           in
           let level2_2_table =
             Toml.Min.of_key_values
               [ (Toml.Min.key "is_less_deep", TBool true) ]
           in

           let level1_table =
             Toml.Min.of_key_values
               [ (Toml.Min.key "level2_1", TTable level2_1_table)
               ; (Toml.Min.key "level2_2", TTable level2_2_table)
               ]
           in

           let top_level_table =
             Toml.Min.of_key_values
               [ (Toml.Min.key "toplevel", TString "ocaml")
               ; (Toml.Min.key "level1", TTable level1_table)
               ]
           in

           assert_equal
             ~printer:(fun x -> x)
             ( String.concat "\n"
                 [ "toplevel = \"ocaml\""
                 ; "[level1.level2_1.level3]"
                 ; "is_deep = true"
                 ; "location = \"basement\""
                 ; "[level1.level2_2]"
                 ; "is_less_deep = true"
                 ]
             ^ "\n" )
             (top_level_table |> Toml.Printer.string_of_table) )
       ]
