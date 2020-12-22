open OUnit

let () =
  let suites =
    "Toml Test Suite"
    >::: [ Parser_test.suite
         ; Key_test.suite
         ; Printer_test.suite
         ; Example.suite
         ; Example4.suite
         ]
  in

  let results = OUnit.run_test_tt_main suites in

  let has_failure = ref false in

  let pp_node fmt = function
    | ListItem n -> Format.fprintf fmt "%d" n
    | Label s -> Format.fprintf fmt "%s" s
  in

  let pp_path fmt path =
    let path = List.map (fun node -> Format.asprintf "%a" pp_node node) path in
    Format.fprintf fmt "%s" (String.concat "/" (List.rev path))
  in

  let check_test_results = function
    | RSuccess p -> Format.ifprintf Format.std_formatter "test %a successful !@." pp_path p
    | RFailure (p, s) | RError (p, s) | RSkip (p, s) | RTodo (p, s) -> begin
      has_failure := true;
      Format.ifprintf Format.std_formatter "test %a wasn't successful: `%s` !@." pp_path p s
    end
  in

  List.iter check_test_results results;

  if !has_failure then exit 1
