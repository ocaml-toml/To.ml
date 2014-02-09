open OUnit
open TomlType
open TomlPprint
open Toml

let input =
"# Test file for TOML
# Only this one tries to emulate a TOML file written by a user of the kind of parser writers probably hate
# This part you'll really hate

[the]
test_string = \"You'll hate me after this - #\"          # \" Annoying, isn't it?

    [the.hard]
    test_array = [ \"] \", \" # \"]      # ] There you go, parse this!
    test_array2 = [ \"Test #11 ]proved that\", \"Experiment #9 was a success\" ]
    # You didn't think it'd as easy as chucking out the last #, did you?
    another_test_string = \" Same thing, but with a string #\"
    harder_test_string = \" And when \\\"'s are in the string, along with # \\\"\"   # \"and comments are there too\"
    # Things will get harder
    
        [the.hard.bit#]
        what? = \"You don't think some user won't do that?\"
        multi_line_array = [
            \"]\",
            # ] Oh yes I did
            ]

# Each of the following keygroups/key value pairs should produce an error. Uncomment to them to test

"

let error1 ="string = \"Anything other than tabs, spaces and newline after a keygroup or key value pair has ended should produce an error unless it is a comment\"   like this"

let error2 ="array = [
         \"This might most likely happen in multiline arrays\",
         Like here,
         \"or here,
         and here\"
         ]     End of array comment, forgot the #"

let error3 ="number = 3.14  pi <--again forgot the #"

let get_value_list tbl =
  Hashtbl.fold
    (fun k v acc -> match v with TValue (v) -> (k, v) :: acc | _ -> acc) tbl []

let toml = Toml.from_string input

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
        (get_table toml "the" |> get_value_list));

    "the.hard" >:: (fun () ->
      assert_equal
        [("test_array", TArray (NodeString ["] "; " # " ]));
         ("test_array2", TArray (NodeString ["Test #11 ]proved that";
                                             "Experiment #9 was a success"]));
         ("another_test_string", TString " Same thing, but with a string #");
         ("harder_test_string",
          TString " And when \"'s are in the string, along with # \"")]
        (get_table (get_table toml "the") "hard" |> get_value_list));

    "the.hard.bit#" >:: (fun () ->
      assert_equal
      [("what?", TString "You don't think some user won't do that?");
       ("multi_line_array", TArray (NodeString ["]"]))]
      (get_table (get_table (get_table toml "the") "hard") "bit#"
       |> get_value_list));

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
