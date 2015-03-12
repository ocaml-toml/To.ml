open TomlInternal.Type

module M = TomlInternal.Type.Map
module K = TomlInternal.Type.Key

let maybe_escape_char fmt ch =
  match ch with
  | '"'  -> Format.pp_print_string fmt "\\\""
  | '\\' -> Format.pp_print_string fmt "\\\\"
  | '\n' -> Format.pp_print_string fmt "\\n"
  | '\t' -> Format.pp_print_string fmt "\\t"
  | _    -> let code = Char.code ch in
            if code <= 31
            then Format.fprintf fmt "\\u%04x" code
            else Format.pp_print_char fmt ch

let pp_bool fmt value = Format.pp_print_bool fmt value

let pp_int fmt value = Format.pp_print_int fmt value

let pp_float fmt value =
  let (frac, int) = modf value in
  if abs_float frac <= epsilon_float
  then Format.fprintf fmt "%.1f" value
  else Format.pp_print_float fmt value

(* Surround string with double quote *)
let pp_string fmt value =
  Format.pp_print_char fmt '"' ;
  String.iter (maybe_escape_char fmt) value ;
  Format.pp_print_char fmt '"'

let pp_date fmt d =
  ISO8601.Permissive.pp_datetimezone fmt (d, 0.)

(* This function is a shim for [Format.pp_print_list] from ocaml 4.02 *)
let pp_list fmt pp_sep printer values =
  match values with
  | []     -> ()
  | [ e ]  -> printer fmt e
  | e :: l -> printer fmt e;
              List.iter (fun v -> pp_sep fmt () ;
                                  printer fmt v) l

let is_table =
  fun _ -> function TTable _ -> true | _ -> false

let rec pp_array fmt a sections =

  let pp_list printer lst =
    Format.pp_print_char fmt '[';
    pp_list fmt (fun fmt () -> Format.pp_print_string fmt ", ") printer lst ;
    Format.pp_print_char fmt ']' in

  match a with
  | NodeEmpty       -> Format.pp_print_string fmt "[]"
  | NodeBool node   -> pp_list pp_bool node
  | NodeInt node    -> pp_list pp_int node
  | NodeFloat node  -> pp_list pp_float node
  | NodeString node -> pp_list pp_string node
  | NodeDate node   -> pp_list pp_date node
  | NodeArray node  -> pp_list (fun fmt arr -> pp_array fmt arr sections) node
  | NodeTable node  ->
     let is_array_of_table =
       fun _ -> function TArray (NodeTable _) -> true | _ -> false in
     List.iter (fun t ->
                (* Don't print the intermediate sections,
                 * if all node are arrays of tables,
                 * print [[x.y.z]] as appropriate instead of [[x]][[y]][[z]] *)
                if not (M.for_all is_array_of_table t)
                then Format.fprintf fmt "[[%s]]\n"
                                    (sections
                                     |> List.map K.to_string
                                     |> String.concat ".");
                pp_table fmt t sections) node

and pp_key fmt k = Format.pp_print_string fmt (K.to_string k)

and pp_nested_keys fmt (ks : K.t list) =
  pp_list fmt (fun fmt () -> Format.pp_print_char fmt '.') pp_key ks

and pp_table fmt t sections =
  (* We need to print non-table values first,
   * otherwise we risk including
   * top-level values in a section by accident *)
  let (subtables, toplevel) = M.partition is_table t in
  let pp_key_value key value = pp_key_value fmt key value sections in

  (* iter () guarantees that keys are returned in ascending order *)
  M.iter pp_key_value toplevel ;
  M.iter pp_key_value subtables

and pp_value fmt v path =
  match v with
  | TBool value   -> pp_bool fmt value
  | TInt value    -> pp_int fmt value
  | TFloat value  -> pp_float fmt value
  | TString value -> pp_string fmt value
  | TDate value   -> pp_date fmt value
  | TArray value  -> pp_array fmt value path
  | TTable value  -> pp_table fmt value path
  | TCommented (c, v) -> pp_value fmt v path ;
                         pp_comment fmt c

and pp_comment fmt c =
  Format.fprintf fmt " # %s\n" c

and pp_key_value fmt key v path =

  let path', add_linebreak = match v with
    | TTable value  ->
       (* Don't print the intermediate path, if all values are tables,
        * print [x.y.z] as appropriate instead of [x][y][z] *)
       let path = path @ [ key ] in
       if not (M.for_all is_table value)
       then Format.fprintf fmt "[%a]\n" pp_nested_keys path ;
       (path, false)
    | TArray (NodeTable tables) -> (path @ [key], false)
    | _ -> Format.fprintf fmt "%s = " (K.to_string key) ;
           (path, true)
  in
  pp_value fmt v path';
  if add_linebreak
  then Format.pp_print_char fmt '\n'

let value fmt v = pp_value fmt v [] ; Format.pp_print_flush fmt ()

let array fmt = function
  | NodeTable t ->
     (* We need the parent section for printing an array of table correctly,
     * otheriwise the header contains [[]] *)
     invalid_arg "Cannot format array of tables, use Toml.Printer.table"
  | x -> pp_array fmt x [];
         Format.pp_print_flush fmt ()

let table fmt t =
  pp_table fmt t [];
  Format.pp_print_flush fmt ()
