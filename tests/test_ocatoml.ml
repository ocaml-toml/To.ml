(**
  * Here is the main file of testing
  *)

open OUnit

let _ =
  let suite = "Main tests" >:::
  [
    "Lexer" >:::
    [
      "Detect strings" >:: (fun () -> OUnit.todo "Not yet !");
      "Detect int" >:: (fun () -> OUnit.todo "Not yet !");
      "Detect floats" >:: (fun () -> OUnit.todo "Not yet !");
      "Detect booleans" >:: (fun () -> OUnit.todo "Not yet !");
      "Detect dates" >:: (fun () -> OUnit.todo "Not gf yet !");
      "Detect comments" >:: (fun () -> OUnit.todo "Not yet !");
    ];

    "Parsing" >:::
    [
      "Parse arrays" >:: (fun () -> OUnit.todo "Not yet !");
      "Parse key values" >:: (fun () -> OUnit.todo "Not yet !");
      "Parse Groups" >:: (fun () -> OUnit.todo "Not yet !");
      "Parse Sub-groups" >:: (fun () -> OUnit.todo "Not yet !");
    ];

    "Huge files" >::: []
  ] in
  Buffer.