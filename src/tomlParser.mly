%{
    open TomlInternal.Type

    type t = Value of value
           | Table of (Key.t, t) Hashtbl.t
           | Tables of ((Key.t, t) Hashtbl.t) list

    (* Indicate if the given table is a [Regular] table (i.e. its name
     * is its real name), or if it is a [ArrayElement] (i.e. its name
     * is the name of the array containing the table). *)
    type table_tag = Regular | ArrayElement

    (* [lookup_table root keys]
     * For a given path [keys], look over [root] and fetch a table.
     * Creates empty subtables all along the way if needed. *)
    let lookup_table root keys =
      List.fold_left
        (fun t k ->
         try match Hashtbl.find t k with
             | Table t   -> t
             | Value _   -> failwith ("lookup_table.")
             | Tables [] -> let sub = Hashtbl.create 0 in
                            Hashtbl.replace t k (Tables [sub]) ;
                            sub
             (* Return the last table defined *)
             | Tables t -> List.hd (List.rev t)
         with Not_found -> let sub = Hashtbl.create 0 in
                           Hashtbl.add t k (Table sub) ;
                           sub)
        root keys

    (* [add_value t k v] add to the value [v], at the key [k],
     * in the table [t]. Fails if a value is already binded to [k]. *)
    let add_value t k v =
      if Hashtbl.mem t k
      then failwith ("add_value")
      else Hashtbl.add t k (Value v)

    (* [add_to_table root ks kvs] add [kvs] to table found following path
     * [ks] from [root] table.
     * Use it for a table not in array of tables. *)
    let add_to_table root ks kvs =
      let t = lookup_table root ks in
      List.iter (fun (k, v) -> add_value t k v) kvs

    (* [add_to_nested_table root ks kvs] add [kvs] to nested
     * table found following path [ks] from [root].
     * Use it for a table which is in an array of tables.  *)
    let add_to_nested_table root ks kvs =

      (* [ts] are intermediate tables key,
       * [k] is the value key. *)
      let (ts, k) = let rec aux acc = function
                      | [ x ]  -> (List.rev acc, x)
                      | h :: q -> aux (h :: acc) q
                      | []     -> assert false
                    in aux [] ks in

      let t = lookup_table root ts in

      (* [insert_in_new_table ts kvs] create a new table, insert
       * [kvs], a (key * value) list into it, and pakc it with
       * tables [ts] into an array of table. *)
      let insert_table ts kvs =
        let t = Hashtbl.create 0 in
        List.iter(fun (k, v) -> add_value t k v) kvs ;
        Tables (ts @ [ t ]) in

      try match Hashtbl.find t k with
          | Tables ts -> Hashtbl.replace t k (insert_table ts kvs);
          | Table _
          | Value _   -> failwith ("add_to_nested_table")
      with Not_found  -> Hashtbl.add t k (insert_table [] kvs)

    (* Convert a value of local type [t] into a [Value.value]  *)
    let rec convert = function
      | Table t   -> TTable (htbl_to_map t)
      | Value v   -> v
      | Tables ts ->
         TArray (NodeTable (List.filter (fun t -> Hashtbl.length t > 0) ts
                            |> List.map htbl_to_map))

    and htbl_to_map h =
      Hashtbl.fold (fun k v map -> Map.add k (convert v) map)
                   h Map.empty

%}

(* OcamlYacc definitions *)
%token <bool> BOOL
%token <int> INTEGER
%token <float> FLOAT
%token <string> STRING
%token <float> DATE
%token <string> KEY
%token LBRACK RBRACK EQUAL EOF COMMA DOT

%start toml

%type <TomlInternal.Type.table> toml
%type <TomlInternal.Type.Key.t * TomlInternal.Type.value> keyValue
%type <TomlInternal.Type.array> array_start

%%
(* Grammar rules *)
toml:
 | h=list(keyValue) q=list(pair(group_header,list(keyValue))) EOF
   { let t = Hashtbl.create 0 in

     List.iter (fun ((tag, ks), kvs) ->
                match tag with
                | Regular      -> add_to_table t ks kvs
                | ArrayElement -> add_to_nested_table t ks kvs)
               (* Create a dummy table with empty key for values
                * which are direct children of root table.  *)
               (((Regular, []), h) :: q) ;

     match convert (Table t) with TTable t -> t | _ -> assert false }

group_header:
 | LBRACK LBRACK k=key_path RBRACK RBRACK { ArrayElement, k }
 | LBRACK k=key_path RBRACK               { Regular, k }

key:
 | STRING { Key.quoted_key_of_string $1 }
 | KEY    { Key.bare_key_of_string $1 }

key_path: k = separated_nonempty_list (DOT, key) { k }

keyValue:
    k=key EQUAL v=value { (k, v) }

value:
    x=BOOL               { TBool x }
  | x=INTEGER            { TInt x }
  | x=FLOAT              { TFloat x }
  | x=STRING             { TString x }
  | x=DATE               { TDate x }
  | LBRACK x=array_start { TArray x }

array_start:
    RBRACK                                  { NodeEmpty }
  | h=BOOL q=array_end(BOOL)                { NodeBool (h :: q) }
  | h=INTEGER q=array_end(INTEGER)          { NodeInt (h :: q) }
  | h=FLOAT q=array_end(FLOAT)              { NodeFloat (h :: q) }
  | h=STRING q=array_end(STRING)            { NodeString (h :: q) }
  | h=DATE q=array_end(DATE)                { NodeDate (h :: q) }
  | LBRACK h=array_start q=nested_array_end { NodeArray (h :: q) }

array_end(param):
    COMMA h=param q=array_end(param) { h :: q }
  | option(COMMA) RBRACK { [] }

nested_array_end:
    COMMA LBRACK h=array_start q=nested_array_end { h :: q }
  | option(COMMA) RBRACK { [] }

%%
