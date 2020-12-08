open OUnit
open Utils

let test_bad_bk k () =
  assert_raises (Toml.Types.Table.Key.Bad_key k) (fun () -> Toml.Min.key k)

let suite =
  "Printing values"
  >::: [ ( "good key" >:: fun () ->
           test_string "\"my_good_unicodé_key\""
             (Toml.Types.Table.Key.to_string
                (Toml.Types.Table.Key.quoted_key_of_string
                   "my_good_unicodé_key")) )
       ; "key with spaces" >:: test_bad_bk "key with spaces"
       ; "key with tab" >:: test_bad_bk "with\ttab"
       ; "key with linefeed" >:: test_bad_bk "with\nlinefeed"
       ; "key with cr" >:: test_bad_bk "with\rcr"
       ; "key with dot" >:: test_bad_bk "with.dot"
       ; "key with [" >:: test_bad_bk "with[bracket"
       ; "key with ]" >:: test_bad_bk "with]bracket"
       ; "key with \"" >:: test_bad_bk "with\"quote"
       ; "key with #" >:: test_bad_bk "with#pound"
       ]
