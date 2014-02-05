open OUnit
open Toml

let parse = Toml.from_string

let bool _ =
  let toml = parse "foo=\"bar\"
                    bar=true
                    bu=[true, true, false]" in
  assert_equal
    true
    (get_bool toml "bar");
  assert_equal
    [true; true; false]
    (get_bool_list toml "bu");
  assert_raises
    (Failure "foo is not a boolean")
    (fun () -> get_bool toml "foo");
  assert_raises
    (Failure "bar is not a boolean array")
    (fun () -> get_bool_list toml "bar")

let int _ =
  let toml = parse "foo=\"bar\"
                    bar=42
                    bu=[-1, 2, -3]" in
  assert_equal
    42
    (get_int toml "bar");
  assert_equal
    [-1; 2; -3]
    (get_int_list toml "bu");
  assert_raises
    (Failure "foo is not an integer")
    (fun () -> get_int toml "foo");
  assert_raises
    (Failure "bar is not an integer array")
    (fun () -> get_int_list toml "bar")

let float _ =
  let toml = parse "foo=\"bar\"
                    bar=42.42
                    bu=[-1.0, 2.0, -3.0]" in
  assert_equal
    42.42
    (get_float toml "bar");
  assert_equal
    [-1.0; 2.0; -3.0]
    (get_float_list toml "bu");
  assert_raises
    (Failure "foo is not a float")
    (fun () -> get_float toml "foo");
  assert_raises
    (Failure "bar is not a float array")
    (fun () -> get_float_list toml "bar")

let string _ =
  let toml = parse "foo=\"bar\"
                    bar=true
                    bu=[\"foo\", \"foo\", \"bar\"]" in
  assert_equal
    "bar"
    (get_string toml "foo");
  assert_equal
    ["foo"; "foo"; "bar"]
    (get_string_list toml "bu");
  assert_raises
    (Failure "bar is not a string")
    (fun () -> get_string toml "bar");
  assert_raises
    (Failure "foo is not a string array")
    (fun () -> get_string_list toml "foo")

let date _ =
  let toml = parse "foo=\"1979-05-27T07:32:00Z\"
                    bar=1979-05-27T07:32:00Z
                    bu=[1979-05-27T07:32:00Z, 1979-05-27T07:32:00Z ]" in
  assert_equal
    "1979-05-27T07:32:00Z"
    (get_date toml "bar");
  assert_equal
    ["1979-05-27T07:32:00Z"; "1979-05-27T07:32:00Z"]
    (get_date_list toml "bu");
  assert_raises
    (Failure "foo is not a date")
    (fun () -> get_date toml "foo");
  assert_raises
    (Failure "bar is not a date array")
    (fun () -> get_date_list toml "bar")

let suite = 
  "Suite" >:::
    ["bool" >:: bool;
     "int" >:: int;
     "flaot" >:: float;
     "string" >:: string;
     "date" >:: date]

let _  =
  run_test_tt_main suite
