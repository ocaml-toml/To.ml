open OUnit
open Utils
open Toml

let find k = Table.find (bk k)

let test_value = assert_equal ~printer:string_of_value

let suite =
  let assert_equal = OUnit.assert_equal in
  "Main tests" >:::
    [
      "Rache Methodology Approved" >:::
        [ "simple key value" >::
            (fun () ->
             let str = "key = \"VaLUe42\"" in
             let toml = Parser.from_string str in
             test_string "VaLUe42" (get_string (bk "key") toml) );

          "Two keys value" >::
            (fun () ->
             let str = "key = \"VaLUe42\"\nkey2=42" in
             let toml = Parser.from_string str in
             test_string "VaLUe42" (get_string (bk "key") toml);
             test_int 42 (get_int (bk "key2") toml));

          "Int" >::
            (fun () ->
             let str = "key = 42\nkey2=-42 \n key3 = +42 \n key4 = 1_2_3_4_5 \n key5=0" in
             let toml = Parser.from_string str in
             test_int 42 (get_int (bk "key") toml);
             test_int (-42) (get_int (bk "key2") toml);
             test_int 42 (get_int (bk "key3") toml);
             test_int 12345 (get_int (bk "key4") toml);
             test_int 0 (get_int (bk "key5") toml));

          "Float key" >::
            (fun () ->
	     let test str =
               let toml = Parser.from_string ("key=" ^ str) in
	       test_float (float_of_string str)
		          (get_float (bk "key") toml) in
	     test "+1.0" ;
	     test "3.1415" ;
	     test "-0.01" ;
	     test "5e+22" ;
	     test "1e6" ;
	     test "-2E-2" ;
	     test "6.626e-34" ) ;
          "Underscore float key" >::
            (fun () ->
              let get_float_value toml_string = Parser.from_string toml_string
                                                |> Table.find (Toml.key "key")
                                                |> Value.To.float
              in
              assert_equal (-1023.03) (get_float_value "key=-1_023.0_3");
              assert_equal (142.301e10) (get_float_value "key=14_2.3_01e1_0");
            );
          "Bool key" >::
            (fun () ->
             let str = "key = true\nkey2=false" in
             let toml = Parser.from_string str in
             test_bool true (get_bool (bk "key") toml);
             test_bool false (get_bool (bk "key2") toml));

          "String" >::
            (fun () ->
	     let test str input =
               let toml = Parser.from_string ("key=\"" ^ input ^ "\"") in
	       test_string str (get_string (bk "key") toml) in
             test "\b" "\\b" ;
             test "\t" "\\t" ;
             test "\n" "\\n" ;
             test "\r" "\\r" ;
             test "\\" "\\\\" ;
             test "\"" "\\\"" ;

             assert_raises
               (Parser.Error
                  ("Error in <string> at line 1 at column 6 (position 6): " ^
                     "Forbidden escaped char",
                   {Parser.source = "<string>";
                    line = 1; column = 6; position = 6}))
               (fun () -> Parser.from_string "key=\"\\j\"");
             assert_raises
               (Parser.Error
                  ("Error in <string> at line 1 at column 30 (position 30): " ^
                     "Unterminated string",
                   {Parser.source = "<string>";
                    line = 1; column = 30; position = 30}))
               (fun () -> Parser.from_string "key=\"This string is not termin"));

          "Multi-lines string" >::
            (fun () ->
	     let str = "key1 = \"\"\"\n\
                        Roses are red\n\
                        Violets are blue\"\"\"" in
	     let toml = Parser.from_string str in
	     test_string "Roses are red\n\
                          Violets are blue"
                         (get_string (bk "key1") toml) ) ;

          "Literal strings" >::
            (fun () ->
             let test input =
               let toml = Parser.from_string ("key = '" ^ input ^ "'") in
               test_string input (get_string (bk "key") toml) in

             test "C:\\Users\\nodejs\\templates" ;
             test "\\\\ServerX\\admin$\\system32\\" ;
             test "Tom \"Dubs\" Preston-Werner" ;
             test "<\\i\\c*\\s*>"  ) ;

          (* TODO: "Multiline literal strings" >:: (fun () -> ...) *)

          "Array key" >::
            (fun () ->
             let str = "key = [true, true, false, true]" in
             let toml = Parser.from_string str in
             assert_equal [true; true; false; true]
                          (get_bool_array (bk "key") toml) ;

             let str = "key = []" in
             let toml = Parser.from_string str in
             assert_equal [] (get_bool_array (bk "key") toml) ;

             let str = "key = [true, true,]" in
             let toml = Parser.from_string str in
             assert_equal [true; true] (get_bool_array (bk "key") toml) ) ;

          "Nested Arrays" >::
            (fun () ->
             let str ="key=[ [1,2],[\"a\",\"b\",\"c\",\"d\"]\n,[] ]" in
             let toml = Parser.from_string str in
             test_value
               ([Toml.Value.Of.Array.int [1; 2];
                 Toml.Value.Of.Array.string ["a";"b";"c";"d"];
                 Toml.Value.Of.Array.bool []]
                |> of_array_array)
               (find "key" toml));

          "Grouped key" >::
            (fun () ->
             let str = "[group1]\nkey = true\nkey2 = 1337" in
             let toml = Parser.from_string str in
             assert_raises Not_found (fun () -> find "key" toml);
             let group1 = get_table (bk "group1") toml in
             test_value (of_bool true) (find "key" group1);
             test_value (of_int 1337) (find "key2" group1));

          "Comment" >::
            (fun () ->
             let str = "[group1]\nkey = true # this is comment" in
             let toml = Parser.from_string str in
             let group1 = get_table (bk "group1") toml in
             test_value (of_bool true) (find "key" group1));

          "Date" >::
            (fun () ->
             let str = "[group1]\nkey = 1979-05-27T07:32:00Z" in
             let toml = Parser.from_string str in
             let group1 = get_table (bk "group1") toml in
             test_value (of_date 296638320.) (find "key" group1));

          "Array of tables" >::
            (fun () ->
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
                         create_table [
                             bk "field1", of_int 1;
                             bk "field2", of_int 2;
                           ];
                         create_table [
                             bk "field1", of_int 10;
                             bk "field2", of_int 20;
                           ];
                       ] |> Toml.Value.Of.array
             in
             let b = create_table_as_value [bk "c", c] in
             let a = create_table_as_value [bk "b", b] in
             let expected = create_table [bk "a", a] in
             assert_table_equal expected toml;
            );

          "Nested array of tables, official example" >::
            (fun () ->
             let str = "[[fruit]]\n\
                        name = \"apple\"\n\
                        [fruit.physical]\n\
                        color = \"red\"\n\
                        shape = \"round\"\n\
                        [[fruit.variety]]\n\
                        name = \"red delicious\"\n\
                        [[fruit.variety]]\n\
                        name = \"granny smith\"\n\
                        [[fruit]]\n\
                        name = \"banana\"\n\
                        [[fruit.variety]]\n\
                        name = \"plantain\"" in
             let toml = Parser.from_string str in

             assert_equal 1 (Toml.Table.cardinal toml);
             assert_bool "" (Toml.Table.mem (bk "fruit") toml);

             let fruits = get_table_array (bk "fruit") toml in
             assert_equal 2 (List.length fruits);

             let apple = List.hd fruits in
             assert_equal 3 (Toml.Table.cardinal apple);
             assert_equal "apple" (get_string (bk "name") apple);

             let physical = get_table (bk "physical") apple in
             let expected_physical = create_table [
                                         bk "color", of_string "red";
                                         bk "shape", of_string "round";
                                       ] in
             assert_table_equal expected_physical physical;

             let apple_varieties = get_table_array (bk "variety") apple in
             assert_equal 2 (List.length apple_varieties);

             let expected_red_delicious =
               create_table [bk "name", of_string "red delicious" ] in
             assert_table_equal expected_red_delicious (List.hd apple_varieties);

             let expected_granny_smith =
               create_table [ bk "name", of_string "granny smith" ] in
             assert_table_equal expected_granny_smith
                        (List.rev apple_varieties |> List.hd);

             let banana = List.rev fruits |> List.hd in
             assert_equal 2 (Toml.Table.cardinal banana);
             assert_equal "banana" (find "name" banana |> to_string);

             let banana_varieties = find "variety" banana |> to_table_array in
             assert_equal 1 (List.length banana_varieties);

             let expected_plantain =
               create_table [ bk "name", of_string "plantain" ] in
             assert_equal expected_plantain (List.hd banana_varieties);
            );

          "Array of tables expected, got table" >::
            (fun () ->
             let str = "[a.b.c]\n\
                        field1 = 1\n\
                        field2 = 2\n\
                        [[a.b.c]]\n\
                        field1 = 10\n\
                        field2 = 20"  in
             assert_raises
               (Parser.Error
                  ("Error in <string> at line 6 \
                    at column 11 (position 63): \
                    c is a table, not an array of tables",
                   { Parser.source = "<string>"; line = 6;
                     column = 11; position = 63; }))
               (fun () -> ignore(Parser.from_string str));
            );

          "Nested array of table, initially empty" >::
            (fun () ->
             let str = [
                 "[[fruit]]";
                 "[vegetable]";
                 "name=\"lettuce\"";
                 "[[fruit]]";
                 "name=\"apple\"";
               ] |> String.concat "\n" in

             let toml = Parser.from_string str in
             assert_equal 2 (Toml.Table.cardinal toml);

             let expected_vegetable = create_table [
                                          bk "name", of_string "lettuce";
                                        ] in
             let vegetable = get_table (bk "vegetable") toml in
             assert_equal expected_vegetable vegetable;

             let fruits = get_table_array (bk "fruit") toml in
             assert_equal 1 (List.length fruits);

             let expected_fruit = create_table [ bk "name", of_string "apple" ] in
             assert_equal expected_fruit (List.hd fruits)
            ) ;

          "Same key, different group" >::
            (fun () ->
             let str = "key=1[group]\nkey = 2" in
             let toml = Parser.from_string str in
             assert_equal 1 (get_int (bk "key") toml);
             assert_equal 2 (get_table (bk "group") toml |> get_int (bk "key")));

          "Unicode" >::
            (fun () ->
             let str = "key=\"\\u03C9\"\n\
                        key2=\"\\u4E2D\\u56FD\\u0021\"" in
             let toml = Parser.from_string str in
             assert_equal "ω" (get_string (bk "key") toml) ;
             assert_equal "中国!" (get_string (bk "key2") toml)) ;

          "Inline table" >::
            (fun () ->
              let str = "key = { it_key1 = 1, it_key2 = '2' }" in
              let toml = Parser.from_string str in
              let expected = create_table [
                  bk"key",
                    create_table_as_value [
                      bk"it_key1", of_int 1;
                      bk"it_key2", of_string "2";
                    ];
                ]
              in
              assert_table_equal expected toml;
            );
          "Empty inline table" >::
            (fun () ->
              let str = "key = {}" in
              let toml = Parser.from_string str in
              let expected = create_table [
                  bk"key",
                  create_table_as_value []
                ]
              in
              assert_table_equal expected toml;
            );
          "Nested inline tables" >::
            (fun () ->
              let str = "key = { it_key1 = 1, it_key2 = '2', it_key3 = { nested_it_key = 'nested value' } }" in
              let toml = Parser.from_string str in
              let expected = create_table [
                  bk"key",
                    create_table_as_value [
                      bk"it_key1", of_int 1;
                      bk"it_key2", of_string "2";
                      bk"it_key3",
                        create_table_as_value [
                          bk"nested_it_key", of_string "nested value";
                        ]
                    ];
                ]
              in
              assert_table_equal expected toml;
            );
          "Error location when endlines in strings" >::
            (fun () ->
             let str =
               "\na = [\"b\"]\n\
                b = \"error here\n\n\
                c = \"should not be reached\"" in
             assert_raises
               (Parser.Error
                  ("Error in <string> at line 3 at column 16 (position 27): Control characters (U+0000 to U+001F) must be escaped",
                   { Parser.source = "<string>";
                     line = 3; column = 16; position = 27; }))
               (fun () -> ignore (Parser.from_string str));
            );

        ]
    ]

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
