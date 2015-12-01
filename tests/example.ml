open OUnit
open TomlTypes
open Utils

(* This test file expects example.toml from official toml repo read *)
let toml = Toml.Parser.from_filename "./example.toml"

let expected =
  Toml.of_key_values
    [ Toml.key "title",
      TString "TOML Example" ;

      Toml.key "owner",
        TTable (Toml.of_key_values
          [ Toml.key "name", TString "Tom Preston-Werner";
            Toml.key "organization", TString "GitHub";
            Toml.key "bio", TString "GitHub Cofounder & CEO\n\
                                Likes tater tots and beer.";
            Toml.key "dob", TDate 296638320. (* 1979-05-27T07:32:00 *) ]) ;

      Toml.key "database",
        TTable (Toml.of_key_values
          [ Toml.key "server", TString "192.168.1.1" ;
            Toml.key "ports", TArray (NodeInt [8001; 8001; 8002]) ;
            Toml.key "connection_max", TInt 5000;
            Toml.key "enabled", TBool true]) ;

      Toml.key "servers",
        TTable (Toml.of_key_values
          [ Toml.key "alpha",
            TTable (Toml.of_key_values [Toml.key "ip", TString "10.0.0.1" ;
                                   Toml.key "dc", TString "eqdc10" ]) ;
            Toml.key "beta",
            TTable (Toml.of_key_values [Toml.key "ip", TString "10.0.0.2";
                                   Toml.key "dc", TString "eqdc10";
                                   Toml.key "country", TString "中国" ] )]) ;

      Toml.key "clients",
        TTable (Toml.of_key_values
          [ Toml.key "data", TArray (NodeArray[
                          NodeString ["gamma"; "delta"];
                          NodeInt [1; 2] ]);
            Toml.key "hosts", TArray (NodeString ["alpha"; "omega"]) ]);

      Toml.key "products",
        TArray (NodeTable [ Toml.of_key_values [
                           Toml.key "name", TString "Hammer";
                           Toml.key "sku", TInt 738594937];
                       Toml.of_key_values [
                           Toml.key "name", TString "Nail";
                           Toml.key "sku", TInt 284758393;
                           Toml.key "color", TString "gray"] ]) ;
    ]


let suite =
  "Official example.toml file" >:::
    [ "example.toml parsing" >:: (fun () -> assert_table_equal toml expected); ]
