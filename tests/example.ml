open OUnit
open TomlType
open TomlPprint
open Toml

(* This test file expects example.toml from official toml repo read *)

let table_array_input =
"# Products (Not supported by To.ml)

  [[products]]
#  name = \"Hammer\"
#  sku = 738594937

#  [[products]]
#  name = \"Nail\"
#  sku = 284758393
#  color = \"gray\"
"

let toml = Toml.from_channel stdin

let printer li =
  "[" ^ (String.concat "; "
        @@ List.map (fun (i, v) -> "\""^i^"\"->"^string_of_val v) li) ^ "]"

let assert_equal x y =
  OUnit.assert_equal ~printer:printer
                     (List.stable_sort compare x) (List.stable_sort compare y)

let test = "Official example.toml file" >:::
  [
    "Root values" >:: (fun () ->
      assert_equal
        (values_to_list toml)
        [("title", TString "TOML Example")]);

    "Owner table" >:: (fun () ->
    assert_equal
      (get_table toml "owner" |> values_to_list)
      [("name", TString "Tom Preston-Werner");
       ("organization", TString "GitHub");
       ("bio", TString "GitHub Cofounder & CEO\nLikes tater tots and beer.");
       ("dob", (TDate {Unix.tm_year=79;Unix.tm_mon=04;Unix.tm_mday=27;
                       Unix.tm_hour=07;Unix.tm_min=32;Unix.tm_sec=0;
                       Unix.tm_wday=(-1);Unix.tm_yday=(-1);
                       Unix.tm_isdst=true}))]);
      
    "Database table" >:: (fun () ->
    assert_equal
      (get_table toml "database" |> values_to_list)
      [("server", TString "192.168.1.1");
       ("ports", TArray (NodeInt [8001; 8001; 8002]));
       ("connection_max", TInt 5000);
       ("enabled", TBool true)]);
    
    "Servers table" >:: (fun () ->
    assert_equal
      ((get_table (get_table toml "servers") "alpha") |> values_to_list)
      [("ip", TString "10.0.0.1");
       ("dc", TString "eqdc10")];
    assert_equal
      ((get_table (get_table toml "servers") "beta") |> values_to_list)
      [("ip", TString "10.0.0.2");
       ("dc", TString "eqdc10");
       ("country", TString "中国")]);

    "Client table" >:: (fun () ->
    assert_equal
      (get_table toml "clients" |> values_to_list)
      [("data", TArray (NodeArray [NodeString ["gamma"; "delta"];
                                   NodeInt [1; 2]]));
       ("hosts", TArray (NodeString ["alpha"; "omega"]))]);

    "Array of table" >:: (fun () ->
    assert_raises
      (Failure "Array of tables is not supported")
      (fun () -> ignore(Toml.from_string table_array_input)))
  ]

let _ = OUnit.run_test_tt_main test

