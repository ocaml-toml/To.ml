open OUnit
open TomlType
open TomlPprint
open Toml

let error1 ="string = \"Anything other than tabs, spaces and newline after a keygroup or key value pair has ended should produce an error unless it is a comment\"   like this"

let error2 ="array = [
         \"This might most likely happen in multiline arrays\",
         Like here,
         \"or here,
         and here\"
         ]     End of array comment, forgot the #"

let error3 ="number = 3.14  pi <--again forgot the #"

let toml = Toml.from_channel stdin

let printer li =
  "[" ^ (String.concat ";\n"
         @@ List.stable_sort compare
         @@ List.map (fun (i, v) -> "\""^i^"\"->"^string_of_val v) li) ^ "]"

let assert_equal x y =
  OUnit.assert_equal ~printer:printer (List.stable_sort compare x) (List.stable_sort compare y)


let test = "Official example.toml file" >:::
  [
    "the" >:: (fun () ->
      assert_equal
        [("test_string", TString "You'll hate me after this - #")]
        (get_table toml "the" |> values_to_list));

    "the.hard" >:: (fun () ->
      assert_equal
        [("test_array", TArray (NodeString ["] "; " # " ]));
         ("test_array2", TArray (NodeString ["Test #11 ]proved that";
                                             "Experiment #9 was a success"]));
         ("another_test_string", TString " Same thing, but with a string #");
         ("harder_test_string",
          TString " And when \"'s are in the string, along with # \"")]
        (get_table (get_table toml "the") "hard" |> values_to_list));

    "the.hard.bit#" >:: (fun () ->
      assert_equal
      [("what?", TString "You don't think some user won't do that?");
       ("multi_line_array", TArray (NodeString ["]"]))]
      (get_table (get_table (get_table toml "the") "hard") "bit#"
       |> values_to_list));

    "Error" >:: (fun () ->
      assert_raises
        (TomlParser.Error)
        (fun () -> ignore(Toml.from_string error1));
      assert_raises
        (TomlParser.Error)
        (fun () -> ignore(Toml.from_string error2));
      assert_raises
        (TomlParser.Error)
        (fun () -> ignore(Toml.from_string error3)))

  ]

let _ = OUnit.run_test_tt_main test
