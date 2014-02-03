open OUnit
open TypeTo
open Pprint

let input =
"# This is a TOML document. Boom.

title = \"TOML Example\"

[owner]
name = \"Tom Preston-Werner\"
organization = \"GitHub\"
bio = \"GitHub Cofounder & CEO\nLikes tater tots and beer.\"
dob = 1979-05-27T07:32:00Z # First class dates? Why not?

[database]
server = \"192.168.1.1\"
ports = [ 8001, 8001, 8002 ]
connection_max = 5000
enabled = true

[servers]

  # You can indent as you please. Tabs or spaces. TOML don't care.
  [servers.alpha]
  ip = \"10.0.0.1\"
  dc = \"eqdc10\"

  [servers.beta]
  ip = \"10.0.0.2\"
  dc = \"eqdc10\"
#  country = \"中国\" # This should be parsed as UTF-8
                    # but To.ml does not support it

[clients]
data = [ [\"gamma\", \"delta\"], [1, 2] ] # just an update to make sure parsers support it

# Line breaks are OK when inside arrays
hosts = [
  \"alpha\",
  \"omega\"
]

# Products (Not supported by To.ml)

#  [[products]]
#  name = \"Hammer\"
#  sku = 738594937

#  [[products]]
#  name = \"Nail\"
#  sku = 284758393
#  color = \"gray\"
"

let get_value_list tbl =
  Hashtbl.fold
    (fun k v acc -> match v with TValue (v) -> (k, v) :: acc | _ -> acc) tbl []

let toml = To.parse input

let printer li =
  "[" ^ (String.concat "; "
        @@ List.map (fun (i, v) -> "\""^i^"\"->"^string_of_val v) li) ^ "]"

let assert_equal x y =
  OUnit.assert_equal ~printer:printer (List.stable_sort compare x) (List.stable_sort compare y)

let test = "Official example.toml file" >:::
  [
    "Root values" >:: (fun () ->
      assert_equal
        (get_value_list toml)
        [("title", TString "TOML Example")]);

    "Owner table" >:: (fun () ->
    assert_equal
      (get_table toml "owner" |> get_value_list)
      [("name", TString "Tom Preston-Werner");
       ("organization", TString "GitHub");
       ("bio", TString "GitHub Cofounder & CEO\nLikes tater tots and beer.");
       ("dob", TDate "1979-05-27T07:32:00Z")]);
      
    "Database table" >:: (fun () ->
    assert_equal
      (get_table toml "database" |> get_value_list)
      [("server", TString "192.168.1.1");
       ("ports", TArray (NodeInt [8001; 8001; 8002]));
       ("connection_max", TInt 5000);
       ("enabled", TBool true)]);
    
    "Servers table" >:: (fun () ->
    assert_equal
      ((get_table (get_table toml "servers") "alpha") |> get_value_list)
      [("ip", TString "10.0.0.1");
       ("dc", TString "eqdc10")];
    assert_equal
      ((get_table (get_table toml "servers") "beta") |> get_value_list)
      [("ip", TString "10.0.0.2");
       ("dc", TString "eqdc10")]);

    "Client table" >:: (fun () ->
    assert_equal
      (get_table toml "clients" |> get_value_list)
      [("data", TArray (NodeArray [NodeString ["gamma"; "delta"];
                                   NodeInt [1; 2]]));
       ("hosts", TArray (NodeString ["alpha"; "omega"]))])
  ]

let _ = OUnit.run_test_tt_main test

