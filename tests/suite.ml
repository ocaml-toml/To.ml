
open OUnit

let _ =
  let suites =
    "Toml Test Suite" >:::
      [
        Parser_test.suite;
        Key_test.suite;
        Printer_test.suite ;
        Example.suite ;
      ] in
  OUnit.run_test_tt_main suites
