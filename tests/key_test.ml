open OUnit

module Toml_key = Toml.Table.Key

let suite = "Printing values" >:::
[
  "good key" >:: (fun () ->
    assert_equal
      "my_good_unicodé_key"
      (Toml_key.of_string "my_good_unicodé_key" |> Toml_key.to_string)
  );
  "key with spaces" >:: (fun () ->
    assert_raises (Toml_key.Bad_key "key with spaces")
    (fun () -> Toml_key.of_string "key with spaces"));
  "key with tab" >:: (fun () ->
    assert_raises (Toml_key.Bad_key "with\ttab")
    (fun () -> Toml_key.of_string "with\ttab"));
  "key with linefeed" >:: (fun () ->
    assert_raises (Toml_key.Bad_key "with\nlinefeed")
    (fun () -> Toml_key.of_string "with\nlinefeed"));
  "key with cr" >:: (fun () ->
    assert_raises (Toml_key.Bad_key "with\rcr")
    (fun () -> Toml_key.of_string "with\rcr"));
  "key with dot" >:: (fun () ->
    assert_raises (Toml_key.Bad_key "with.dot")
    (fun () -> Toml_key.of_string "with.dot"));
  "key with [" >:: (fun () ->
    assert_raises (Toml_key.Bad_key "with[bracket")
    (fun () -> Toml_key.of_string "with[bracket"));
  "key with ]" >:: (fun () ->
    assert_raises (Toml_key.Bad_key "with]bracket")
    (fun () -> Toml_key.of_string "with]bracket"));
  "key with \"" >:: (fun () ->
    assert_raises (Toml_key.Bad_key "with\"quote")
    (fun () -> Toml_key.of_string "with\"quote"));
  "key with #" >:: (fun () ->
    assert_raises (Toml_key.Bad_key "with#pound")
    (fun () -> Toml_key.of_string "with#pound"));
]

