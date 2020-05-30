open OUnit
open Utils

let test_must_quote key () =
  let quoted = TomlTypes.Table.Key.to_string (Toml.key key) in
  assert( not (String.equal key quoted));
;;

let suite =
  "Printing values" >:::
    [

      "good key" >::
        (fun () ->
         test_string "\"my_good_unicodé_key\""
                     (TomlTypes.Table.Key.to_string
                        (TomlTypes.Table.Key.of_string "my_good_unicodé_key")) );

      "key with spaces" >:: test_must_quote "key with spaces" ;

      "key with tab" >:: test_must_quote "with\ttab" ;

      "key with linefeed" >:: test_must_quote "with\nlinefeed" ;

      "key with cr" >:: test_must_quote "with\rcr" ;

      "key with dot" >:: test_must_quote "with.dot" ;

      "key with [" >:: test_must_quote "with[bracket" ;

      "key with ]" >:: test_must_quote "with]bracket" ;

      "key with \"" >:: test_must_quote "with\"quote" ;

      "key with #" >:: test_must_quote "with#pound" ;
    ]
