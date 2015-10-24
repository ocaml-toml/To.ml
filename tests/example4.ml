open OUnit
open Toml
open Utils

(* This test file expects example.toml from official toml repo read *)
let toml = Parser.from_filename "./example4.toml"

let test expected testing =
  fun () ->  OUnit.assert_equal
               ~cmp:(fun x y -> Compare.table x y == 0)
               ~printer:(fun x -> let buf = Buffer.create 42 in
                                  Printer.table
			            (Format.formatter_of_buffer buf) x ;
		                  Buffer.contents buf)
               expected testing

let expected =
  create_table [ 
    bk"table",
      create_table_as_value [
        bk"key", of_string "value";
        bk"subtable",
          create_table_as_value [
            bk"key", of_string "another value";
            ]; 
        bk"inline",
          create_table_as_value [
            bk"name",
              create_table_as_value [
                bk"first", of_string "Tom";
                bk"last", of_string "Preston-Werner";
              ];
            bk"point",
              create_table_as_value [
                bk"x", of_int 1;
                bk"y", of_int 2;
              ];
          ];
      ];
    bk"x",
      create_table_as_value [
        bk"y",
        create_table_as_value [
          bk"z",
          create_table_as_value [
            bk"w",
            create_table_as_value []
          ];
        ];
      ];
    bk"string",
      create_table_as_value [
        bk"basic",
          create_table_as_value [
            bk"basic",
              of_string "I'm a string. \"You can quote me\". Name\tJosé\nLocation\tSF.";
          ];
        bk"multiline",
          create_table_as_value [
            bk"key1",
              of_string "One\nTwo";
            bk"key2",
              of_string "One\nTwo";
            bk"key3",
              of_string "One\nTwo";
            bk"continued",
              create_table_as_value [
                bk"key1",
                  of_string "The quick brown fox jumps over the lazy dog.";
                bk"key2",
                  of_string "The quick brown fox jumps over the lazy dog.";
                bk"key3",
                  of_string "The quick brown fox jumps over the lazy dog.";
              ];
          ];
        bk"literal",
          create_table_as_value [
            bk"winpath",
              of_string "C:\\Users\\nodejs\\templates";
            bk"winpath2",
              of_string "\\\\ServerX\\admin$\\system32\\";
            bk"quoted",
              of_string "Tom \"Dubs\" Preston-Werner";
            bk"regex",
              of_string "<\\i\\c*\\s*>";
            bk"multiline",
              create_table_as_value [
                bk"regex2",
                of_string "I [dw]on't need \\d{2} apples";
                bk"lines",
                  of_string (
                    String.concat "\n" [
                      "The first newline is";
                      "trimmed in raw strings.";
                      "   All other whitespace";
                      "   is preserved.";
                      "";
                    ]
                  )
              ]
          ];
      ];
    bk"integer",
      create_table_as_value [
        bk"key1", of_int 99;
        bk"key2", of_int 42;
        bk"key3", of_int 0;
        bk"key4", of_int (-17);
        bk"underscores",
          create_table_as_value [
            bk"key1", of_int 1_000;
            bk"key2", of_int 5_349_221;
            bk"key3", of_int 1_2_3_4_5;
          ]
      ];
    bk"float",
      create_table_as_value [
        bk"fractional",
          create_table_as_value [
            bk"key1", of_float 1.0;
            bk"key2", of_float 3.1415;
            bk"key3", of_float (-0.01);
          ];
        bk"exponent",
          create_table_as_value [
            bk"key1", of_float 5e+22;
            bk"key2", of_float 1e6;
            bk"key3", of_float (-2E-2);
          ];
        bk"both",
          create_table_as_value [
            bk"key", of_float 6.626e-34;
          ];
        bk"underscores",
          create_table_as_value [
            bk"key1", of_float 9_224_617.445_991_228_313;
            bk"key2", of_float 1e1_000;
          ];
      ];
    bk"boolean",
      create_table_as_value [
        bk"True", of_bool true;
        bk"False",of_bool false;
      ];
    bk"datetime",
      create_table_as_value [
        bk"key1", of_date 296638320.;
        bk"key2", of_date 296638320.;
        bk"key3", of_date 296638320.999999;
      ];
    bk"array",
      create_table_as_value [
        bk"key1", of_int_array [1; 2; 3];
        bk"key2", of_string_array ["red"; "yellow"; "green"];
        bk"key3", of_array_array [
          Toml.Value.Of.Array.int [1; 2];
          Toml.Value.Of.Array.int [3; 4; 5];
        ];
        bk"key4", of_array_array [
          Toml.Value.Of.Array.int [1; 2];
          Toml.Value.Of.Array.string ["a"; "b"; "c"];
        ];
        bk"key5", of_int_array [1; 2; 3];
        bk"key6", of_int_array [1; 2];
      ];
    bk"products",
      of_table_array [
        create_table [
          bk"name", of_string "Hammer";
          bk"sku", of_int 738594937;
        ];
        create_table [
          bk"name", of_string "Nail";
          bk"sku", of_int 284758393;
          bk"color", of_string "gray";
        ]
      ];
    bk"fruit",
      of_table_array [
        create_table [
          bk"name", of_string "apple";
          bk"physical",
            create_table_as_value [
                bk"color", of_string "red";
                bk"shape", of_string "round";
            ];
          bk"variety",
            of_table_array [
              create_table [
                bk"name", of_string "red delicious";
              ];
              create_table [
                bk"name", of_string "granny smith";
              ];
            ];
          ];
          create_table [
            bk"name", of_string "banana";
            bk"variety",
              of_table_array [
                create_table [
                  bk"name", of_string "plantain";
                ];
            ];
        ];
      ]
  ]

let suite =
  "Official example.toml file" >:::
    [ "example4.toml parsing" >:: test toml expected ; ]
