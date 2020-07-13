open OUnit
open Toml.Types
open Utils

(* This test file expects example.toml from official toml repo read *)
let toml = Toml.Parser.(from_filename "./example4.toml" |> unsafe)

let expected =
  Toml.of_key_values [
    Toml.key "table",
      TTable (Toml.of_key_values [
        Toml.key "key", TString "value";
        Toml.key "subtable",
          TTable (Toml.of_key_values [
            Toml.key "key", TString "another value";
            ]); 
        Toml.key "inline",
          TTable (Toml.of_key_values [
            Toml.key "name",
              TTable (Toml.of_key_values [
                Toml.key "first", TString "Tom";
                Toml.key "last", TString "Preston-Werner";
              ]);
            Toml.key "point",
              TTable (Toml.of_key_values [
                Toml.key "x", TInt 1;
                Toml.key "y", TInt 2;
              ]);
          ]);
      ]);
    Toml.key "x",
      TTable (Toml.of_key_values [
        Toml.key "y",
        TTable (Toml.of_key_values [
          Toml.key "z",
          TTable (Toml.of_key_values [
            Toml.key "w",
            TTable (Toml.of_key_values [])
          ]);
        ]);
      ]);
    Toml.key "string",
      TTable (Toml.of_key_values [
        Toml.key "basic",
          TTable (Toml.of_key_values [
            Toml.key "basic",
              TString "I'm a string. \"You can quote me\". Name\tJosé\nLocation\tSF.";
          ]);
        Toml.key "multiline",
          TTable (Toml.of_key_values [
            Toml.key "key1",
              TString "One\nTwo";
            Toml.key "key2",
              TString "One\nTwo";
            Toml.key "key3",
              TString "One\nTwo";
            Toml.key "continued",
              TTable (Toml.of_key_values [
                Toml.key "key1",
                  TString "The quick brown fox jumps over the lazy dog.";
                Toml.key "key2",
                  TString "The quick brown fox jumps over the lazy dog.";
                Toml.key "key3",
                  TString "The quick brown fox jumps over the lazy dog.";
              ]);
          ]);
        Toml.key "literal",
          TTable (Toml.of_key_values [
            Toml.key "winpath",
              TString "C:\\Users\\nodejs\\templates";
            Toml.key "winpath2",
              TString "\\\\ServerX\\admin$\\system32\\";
            Toml.key "quoted",
              TString "Tom \"Dubs\" Preston-Werner";
            Toml.key "regex",
              TString "<\\i\\c*\\s*>";
            Toml.key "multiline",
              TTable (Toml.of_key_values [
                Toml.key "regex2",
                TString "I [dw]on't need \\d{2} apples";
                Toml.key "lines",
                  TString (
                    String.concat "\n" [
                      "The first newline is";
                      "trimmed in raw strings.";
                      "   All other whitespace";
                      "   is preserved.";
                      "";
                    ]
                  )
              ])
          ]);
      ]);
    Toml.key "integer",
      TTable (Toml.of_key_values [
        Toml.key "key1", TInt 99;
        Toml.key "key2", TInt 42;
        Toml.key "key3", TInt 0;
        Toml.key "key4", TInt (-17);
        Toml.key "underscores",
          TTable (Toml.of_key_values [
            Toml.key "key1", TInt 1_000;
            Toml.key "key2", TInt 5_349_221;
            Toml.key "key3", TInt 1_2_3_4_5;
          ])
      ]);
    Toml.key "float",
      TTable (Toml.of_key_values [
        Toml.key "fractional",
          TTable (Toml.of_key_values [
            Toml.key "key1", TFloat 1.0;
            Toml.key "key2", TFloat 3.1415;
            Toml.key "key3", TFloat (-0.01);
          ]);
        Toml.key "exponent",
          TTable (Toml.of_key_values [
            Toml.key "key1", TFloat 5e+22;
            Toml.key "key2", TFloat 1e6;
            Toml.key "key3", TFloat (-2E-2);
          ]);
        Toml.key "both",
          TTable (Toml.of_key_values [
            Toml.key "key", TFloat 6.626e-34;
          ]);
        Toml.key "underscores",
          TTable (Toml.of_key_values [
            Toml.key "key1", TFloat 9_224_617.445_991_228_313;
            Toml.key "key2", TFloat 1e1_000;
          ]);
      ]);
    Toml.key "boolean",
      TTable (Toml.of_key_values [
        Toml.key "True", TBool true;
        Toml.key "False", TBool false;
      ]);
    Toml.key "datetime",
      TTable (Toml.of_key_values [
        Toml.key "key1", TDate 296638320.;
        Toml.key "key2", TDate 296638320.;
        Toml.key "key3", TDate 296638320.999999;
      ]);
    Toml.key "array",
      TTable (Toml.of_key_values [
        Toml.key "key1", TArray (NodeInt [1; 2; 3]);
        Toml.key "key2", TArray (NodeString ["red"; "yellow"; "green"]);
        Toml.key "key3", TArray (NodeArray [
          NodeInt [1; 2];
          NodeInt [3; 4; 5];
        ]);
        Toml.key "key4", TArray (NodeArray [
          NodeInt [1; 2];
          NodeString ["a"; "b"; "c"];
        ]);
        Toml.key "key5", TArray(NodeInt [1; 2; 3]);
        Toml.key "key6", TArray(NodeInt [1; 2]);
        Toml.key "inline", TTable (Toml.of_key_values [
            Toml.key "points",
              TArray (NodeTable [
                Toml.of_key_values [
                  Toml.key "x", TInt 1;
                  Toml.key "y", TInt 2;
                  Toml.key "z", TInt 3;
                ];
                Toml.of_key_values [
                  Toml.key "x", TInt 7;
                  Toml.key "y", TInt 8;
                  Toml.key "z", TInt 9;
                ];
                Toml.of_key_values [
                  Toml.key "x", TInt 2;
                  Toml.key "y", TInt 4;
                  Toml.key "z", TInt 8;
                ];
              ])
          ])
      ]);
    Toml.key "products",
      TArray (NodeTable [
        Toml.of_key_values [
          Toml.key "name", TString "Hammer";
          Toml.key "sku", TInt 738594937;
        ];
        Toml.of_key_values [
          Toml.key "name", TString "Nail";
          Toml.key "sku", TInt 284758393;
          Toml.key "color", TString "gray";
        ]
      ]);
    Toml.key "fruit",
      TArray (NodeTable [
        Toml.of_key_values [
          Toml.key "name", TString "apple";
          Toml.key "physical",
            TTable (Toml.of_key_values [
                Toml.key "color", TString "red";
                Toml.key "shape", TString "round";
            ]);
          Toml.key "variety",
            TArray (NodeTable [
              Toml.of_key_values [
                Toml.key "name", TString "red delicious";
              ];
              Toml.of_key_values [
                Toml.key "name", TString "granny smith";
              ];
            ]);
          ];
          Toml.of_key_values [
            Toml.key "name", TString "banana";
            Toml.key "variety",
              TArray (NodeTable [
                Toml.of_key_values [
                  Toml.key "name", TString "plantain";
                ];
            ]);
        ];
      ]);
  ]
>>>>>>> d87863d (Add support for arrays of inline tables)

let suite =
  "Official example.toml file"
  >::: [ ("example4.toml parsing" >:: fun () -> assert_table_equal toml expected)
       ]
