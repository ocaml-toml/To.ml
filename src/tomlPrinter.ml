open TomlInternal.Type

module TomlMap = TomlInternal.Type.Map

let maybe_escape_char formatter ch =
  match ch with
  | '"'  -> Format.pp_print_string formatter "\\\""
  | '\\' -> Format.pp_print_string formatter "\\\\"
  | '\n' -> Format.pp_print_string formatter "\\n"
  | '\t' -> Format.pp_print_string formatter "\\t"
  | _    ->
    let code = Char.code ch in
    if code <= 31
    then Format.fprintf formatter "\\u%04x" code
    else Format.pp_print_char formatter ch

let print_bool formatter value = Format.pp_print_bool formatter value

let print_int formatter value = Format.pp_print_int formatter value

let print_float formatter value = Format.pp_print_float formatter value

let print_string formatter value =
  Format.pp_print_char formatter '"' ;
  String.iter (maybe_escape_char formatter) value ;
  Format.pp_print_char formatter '"'

let print_date formatter d =
  let open UnixLabels
  in
  Format.fprintf formatter "%4d-%02d-%02dT%02d:%02d:%02dZ"
    (1900 + d.tm_year) (d.tm_mon + 1) d.tm_mday
    d.tm_hour d.tm_min d.tm_sec

let rec print_array formatter toml_array =
  let print_list values ~f:print_item_func =
    let pp_sep formatter () = Format.pp_print_string formatter ", "
    in
    Format.pp_print_char formatter '[';
    Format.pp_print_list ~pp_sep print_item_func formatter values;
    Format.pp_print_char formatter ']'
  in
  match toml_array with
  | NodeBool values   -> print_list values ~f:print_bool
  | NodeInt values    -> print_list values ~f:print_int
  | NodeFloat values  -> print_list values ~f:print_float
  | NodeString values -> print_list values ~f:print_string
  | NodeDate values   -> print_list values ~f:print_date
  | NodeArray values  -> print_list values ~f:print_array
  | NodeEmpty         -> Format.pp_print_string formatter "[]"

let is_table = fun _ -> function TTable _ -> true | _ -> false

let rec print_table formatter toml_table sections =
    (*
     * We need to print non-table values first, otherwise we risk including
     * top-level values in a section by accident
     *)
  let (table_with_table_values, table_with_non_table_values) =
    TomlMap.partition is_table toml_table
  in
  let print_key_value key value =
    print_value_with_key formatter key value sections
  in
  (* iter() guarantees that keys are returned in ascending order *)
  TomlMap.iter print_key_value table_with_non_table_values;
  TomlMap.iter print_key_value table_with_table_values
and print_value formatter toml_value sections =
  match toml_value with
  | TBool value   -> print_bool formatter value
  | TInt value    -> print_int formatter value
  | TFloat value  -> print_float formatter value
  | TString value -> print_string formatter value
  | TDate value   -> print_date formatter value
  | TArray value  -> print_array formatter value
  | TTable value  -> print_table formatter value sections
and print_value_with_key formatter key toml_value sections =
  let sections', add_linebreak = match toml_value with
    | TTable value  ->
      let sections_with_key = sections @ [key] in
      (*
       * Don't print the intermediate sections, if all values are tables,
       * print [x.y.z] as appropriate instead of [x][y][z]
       *)
      if not (TomlMap.for_all is_table value)
      then Format.fprintf formatter "[%s]\n"
          (String.concat "." sections_with_key) ;
      (sections_with_key, false)
    | _             ->
      Format.fprintf formatter "%s = " key;
      (sections, true)
  in
  print_value formatter toml_value sections';
  if add_linebreak
  then Format.pp_print_char formatter '\n'

let value formatter toml_value =
  print_value formatter toml_value [];
  Format.pp_print_flush formatter ()

let array formatter toml_array =
  print_array formatter toml_array;
  Format.pp_print_flush formatter ()

let table formatter toml_table =
  print_table formatter toml_table [];
  Format.pp_print_flush formatter ()
