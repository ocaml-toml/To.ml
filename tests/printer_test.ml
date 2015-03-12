open OUnit
open Utils
open Toml

let test fn expected testing =
  fun () -> assert_equal ~printer:(fun x -> x)
                         expected
                         (string_of_value (fn testing))

let test_string = test of_string
let test_bool = test of_bool
let test_int = test of_int
let test_float = test of_float
let test_date = test of_date

let test_int_array = test of_int_array
let test_bool_array = test of_bool_array
let test_float_array = test of_float_array
let test_string_array = test of_string_array
let test_date_array = test of_date_array

let test_array_array =
  test of_array_array

let test_table expected testing =
  fun () -> assert_equal ~printer:(fun x -> x)
                         (String.concat "\n" expected ^ "\n")
                         (toml_table testing)

let suite =
  "Printing simple" >:::
    [
      "values string" >::
        test_string  "\"string value\"" "string value" ;
      "string with control chars" >::
        test_string "\"str\\\\ing\\t\\n\\u0002\\\"\"" "str\\ing\t\n\002\"" ;
      "string with accented chars" >::
        test_string "\"\195\169\"" "\195\169" ;
      "boolean true" >::
        test_bool "true" true ;
      "boolean false" >::
        test_bool "false" false ;
      "positive int" >::
        test_int "42" 42 ;
      "negative int" >::
        test_int "-42" (-42) ;
      "positive float" >::
        test_float "42.24" 42.24 ;
      "negative float" >::
        test_float "-42.24" (-42.24) ;
      "round float" >::
        test_float "1.0" 1. ;
      "negative round float" >::
        test_float "-1.0" (-1.) ;
      "date (1)" >::
        (test_date "1979-05-27T07:32:00+00:00" 296638320.) ;
      "date (2)" >::
        (test_date "1970-01-01T00:00:00+00:00" 0.) ;

      "empty int array" >::
        test_int_array "[]" [] ;
      "int array" >::
        test_int_array "[4, 5]"  [4; 5] ;
      "empty bool array" >::
        test_bool_array "[]" [] ;
      "bool array" >::
        test_bool_array "[true, false]" [true;false] ;
      "empty float array" >::
        test_float_array "[]" [] ;
      "float array" >::
        test_float_array "[4.2, 3.14]"  [4.2; 3.14] ;
      "empty string array" >::
        test_string_array "[]" [] ;
      "string array" >::
        test_string_array "[\"a\", \"b\"]" ["a";"b"] ;
      "empty date array" >::
        test_date_array "[]" [] ;
      "date array" >::
        (let open UnixLabels in
         test_date_array "[1979-05-27T07:32:00+00:00, \
                          1979-05-27T08:38:40+00:00]"
                         [ 296638320.; 296642320.]) ;

      "table" >::
        test_table
          [ "[dog]"; "type = \"golden retriever\"" ]
          [ bk"dog", of_table (create_table
                                [bk"type", of_string "golden retriever"])] ;

      "nested tables" >::
        test_table
          [ "[dog.tater]"; "type = \"pug\"" ]
          [ bk"dog", of_table (create_table
                                 [bk"tater", of_table (create_table
                                                         [bk"type",
                                                          of_string "pug"])])] ;

      "table of empty array of tables" >::
        (fun () ->
         assert_equal ~printer:(fun x -> x) ""
                      (string_of_table
                         (create_table [bk"dog", [] |> of_table_array]))) ;

      "table of array of tables" >::
        test_table
          [ "[[dog]]" ; "[dog.tater]"; "type = \"pug\""]
          [bk"dog", [create_table
                     [bk"tater", of_table (create_table
                                             [bk"type", of_string "pug"])]
                  ] |> of_table_array] ;

      "table of nested array of tables" >::
        test_table
          [ "[[dog]]"; "[dog.tater]"; "type = \"pug\"";
            "[[dog.dalmatian]]"; "number = 1";
            "[[dog.dalmatian]]"; "number = 2" ]

          [bk"dog",
           [ create_table
               [bk"tater", of_table (create_table
                                        [bk"type", of_string "pug"])] ;
             create_table
               [bk"dalmatian",
                 [ create_table [bk"number", of_int 1];
                   create_table [bk"number", of_int 2] ]
                 |> of_table_array ] ]
           |> of_table_array] ;

      "empty array of arrays" >::
        test_array_array "[]" [] ;

      "array of empty arrays" >::
        test_array_array "[[]]" [V.Of.Array.int []] ;

      "array of arrays" >::
        test_array_array "[[2341, 2242], [true]]"
                         [ V.Of.Array.int [2341 ; 2242] ;
                           V.Of.Array.bool [true] ] ;
      "empty array of tables" >::
        (fun () ->
         assert_raises
           (Invalid_argument "Cannot format array of tables, \
                              use Toml.Printer.table")
           (fun () -> ignore(string_of_array (V.Of.Array.table [])))) ;

      "array of tables" >::
        (fun () ->
         assert_raises
           (Invalid_argument "Cannot format array of tables, \
                              use Toml.Printer.table")
           (fun () -> ignore (string_of_array
                                (V.Of.Array.table
                                   [ create_table [bk"number", of_int 1];
                                     create_table [bk"number", of_int 2]])))) ;

      "mixed example" >::
        (fun () ->
         let level3_table =
           create_table [ bk "is_deep", of_bool true ;
                          bk "location", of_string "basement" ]
         in

         let level2_1_table = create_table [bk "level3",
                                            of_table level3_table] in
         let level2_2_table = create_table [bk "is_less_deep",
                                            of_bool true] in

         let level1_table =
           create_table [bk "level2_1", of_table level2_1_table;
                         bk "level2_2", of_table level2_2_table]
         in

         let top_level_table =
           create_table [bk "toplevel", of_string "ocaml" ;
                         bk "level1", of_table level1_table]
         in

         assert_equal ~printer:(fun x -> x)
           ((String.concat "\n" [ "toplevel = \"ocaml\"";
                                  "[level1.level2_1.level3]";
                                  "is_deep = true";
                                  "location = \"basement\"";
                                  "[level1.level2_2]";
                                  "is_less_deep = true";]) ^ "\n")
           (top_level_table |> string_of_table));


    ]
