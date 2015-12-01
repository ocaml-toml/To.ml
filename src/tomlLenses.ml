(*
let (|-) f g x = g (f x)



type ('a, 'b) t = {
    get : 'a -> 'b;
    set : 'b -> 'a -> 'a;
}

let modify (l:(('a, 'b)t)) (f:('b -> 'b)) (a:'a) =
  let value = l.get a in
  let new_value = f value in
  l.set new_value a

let compose l1 l2 = {
    get = l2.get |- l1.get;
    (*set = l1.set |- (modify l2)*)
    set = fun v -> modify l2 (l1.set v);
}

    TomlTypes.(
      match Table.find (key "foo") with
      | Some x -> match Table.find (key "bar") with
                  | Some v -> match v with Int v -> Some v | _ -> None
                  | _ -> None
      | None
    )

let compose 
   *)

(* Utils *)
(*

let safe_nth idx lst =
  try
    let value = List.nth lst idx
    in
    Some value
  with Failure "nth" -> None
*)
(* Composition *)
    (*
let (>~) f g x =
  match f x with
  | Some r -> g r
  | None -> None
       *)
(*
let nth_table idx (value:TomlTypes.value) =
  let open TomlTypes in
  match value with
  | TArray (NodeTable arr) -> safe_nth idx arr
  | _ -> None
*)
(* getters *)
(*
  key "a" >~ key "b" >~ key "c" >~ string "c" (TomlTypes.TTable toml) 
*)

let safe_find key table =
  try
    let value = TomlTypes.Table.find (TomlTypes.Table.Key.bare_key_of_string
                                        key) table
    in
    Some value
  with Not_found -> None

(* [string -> ] TomlTypes.TTable t *)

(* setters *)

(* set value parent -> parent *)
    (*
let modify lens f parent =
  match lens.get parent with
  | Some old_value  -> begin
      let new_value = f old_value in
      Some (lens.set new_value parent)
    end        
  | None  -> None

let set_key (key, new_value) (value:TomlTypes.value) =
  match value with
  | TomlTypes.TTable t ->
    Some (TomlTypes.TTable (TomlTypes.Table.add (TomlTypes.Table.Key.bare_key_of_string key)
            (new_value) t))
  | _ -> None

       *)

type ('a, 'b) lens = {
  get: 'a -> 'b option;
  set: 'b -> 'a -> 'a option;
}

let key k =
  {
    get = (fun value -> safe_find k value);
    set = (fun new_value value ->
          Some (TomlTypes.Table.add (TomlTypes.Table.Key.bare_key_of_string k)
                                    (new_value) value)
      )
  }

let bool = {
  get = (fun (value:TomlTypes.value) ->
      match value with
      | TomlTypes.TBool v -> Some v
      | _ -> None);
  set = (fun new_value value -> Some (TomlTypes.TBool new_value))
}

let int = {
  get = (fun (value:TomlTypes.value) ->
      match value with
      | TomlTypes.TInt v -> Some v
      | _ -> None);
  set = (fun new_value value -> Some (TomlTypes.TInt new_value))
}

let float = {
  get = (fun (value:TomlTypes.value) ->
      match value with
      | TomlTypes.TFloat v -> Some v
      | _ -> None);
  set = (fun new_value value -> Some (TomlTypes.TFloat new_value))
}

let string = {
  get = (fun (value:TomlTypes.value) ->
      match value with
      | TomlTypes.TString v -> Some v
      | _ -> None);
  set = (fun new_value value -> Some (TomlTypes.TString new_value))
}

let date = {
  get = (fun (value:TomlTypes.value) ->
      match value with
      | TomlTypes.TDate v -> Some v
      | _ -> None);
  set = (fun new_value value -> Some (TomlTypes.TDate new_value))
}

let array = {
  get = (fun (value:TomlTypes.value) ->
      match value with
      | TomlTypes.TArray v -> Some v
      | _ -> None);
  set = (fun new_value value -> Some (TomlTypes.TArray new_value))
}

let table = {
  get = (fun (value:TomlTypes.value) ->
      match value with
      | TomlTypes.TTable v -> Some v
      | _ -> None);
  set = (fun new_value value -> Some (TomlTypes.TTable new_value))
}

let strings = {
  get = (fun (value:TomlTypes.array) ->
      match value with
      | TomlTypes.NodeString v -> Some v
      | TomlTypes.NodeEmpty -> Some []
      | _ -> None);
  set = (fun new_value value -> Some (TomlTypes.NodeString new_value))
}

let bools = {
  get = (fun (value:TomlTypes.array) ->
      match value with
      | TomlTypes.NodeBool v -> Some v
      | TomlTypes.NodeEmpty -> Some []
      | _ -> None);
  set = (fun new_value value -> Some (TomlTypes.NodeBool new_value))
}

let ints = {
  get = (fun (value:TomlTypes.array) ->
      match value with
      | TomlTypes.NodeInt v -> Some v
      | TomlTypes.NodeEmpty -> Some []
      | _ -> None);
  set = (fun new_value value -> Some (TomlTypes.NodeInt new_value))
}

let floats = {
  get = (fun (value:TomlTypes.array) ->
      match value with
      | TomlTypes.NodeFloat v -> Some v
      | TomlTypes.NodeEmpty -> Some []
      | _ -> None);
  set = (fun new_value value -> Some (TomlTypes.NodeFloat new_value))
}

let dates = {
  get = (fun (value:TomlTypes.array) ->
      match value with
      | TomlTypes.NodeDate v -> Some v
      | TomlTypes.NodeEmpty -> Some []
      | _ -> None);
  set = (fun new_value value -> Some (TomlTypes.NodeDate new_value))
}

let arrays = {
  get = (fun (value:TomlTypes.array) ->
      match value with
      | TomlTypes.NodeArray v -> Some v
      | TomlTypes.NodeEmpty -> Some []
      | _ -> None);
  set = (fun new_value value -> Some (TomlTypes.NodeArray new_value))
}

let tables = {
  get = (fun (value:TomlTypes.array) ->
      match value with
      | TomlTypes.NodeTable v -> Some v
      | TomlTypes.NodeEmpty -> Some []
      | _ -> None);
  set = (fun new_value value -> Some (TomlTypes.NodeTable new_value))
}

let safe_replace idx new_value lst =
  if idx < 0 then
    raise @@ Invalid_argument "safe_replace";

  let rec replace_func rev_head tail current_idx =
    if current_idx = idx then
      Some ( (List.rev rev_head) @ [new_value] @ tail)
    else
      match tail with
      | []          -> None
      | x::new_tail -> replace_func (x::rev_head) new_tail (current_idx + 1)
      
  in
  let initial_head = [] in
  let initial_tail = lst in
  let initial_idx = 0 in
  replace_func initial_head initial_tail initial_idx
   
(*
let index idx =
  {
    get = (fun (value:TomlTypes.value) ->
      match value with
      | TomlTypes.TArray lst -> begin
          match safe_nth idx lst with
          | Some new_lst  -> Some (TomlTypes.TArray new_lst)
          | None -> None
        end
      | _ -> None);
    set = (fun new_value value ->
        match value with
        | TomlTypes.TArray lst ->
          begin
            match safe_replace idx new_value lst with
            | Some new_lst -> Some (TomlTypes.TArray new_lst)
            | _ -> None
          end
        | _ -> None
      )
  }
*)

let (|-) (f:('a -> 'b option)) (g:'b -> 'c option) (x:'a) =
  match f x with
  | Some r -> g r
  | None -> None

(* original: ('a, 'b) t -> ('b -> 'b) -> 'a -> 'a *)
let modify (l:('a, 'b) lens) (f:('b -> 'b option)) (a:'a) =
  match l.get a with
  | Some old_value -> begin
      match f old_value with
      | Some new_value -> l.set new_value a
      | None -> None
    end
  | None -> None

let compose (l1:('a, 'b) lens) (l2:('c, 'a)lens) = {
    get = l2.get |- l1.get;
    set = fun v -> modify l2 (l1.set v);
}

let (|--) l1 l2 = compose l2 l1

let get record lens = lens.get record

let set value record lens = lens.set value record

(*
    modify: ('b 'c) lens -> ('a 
    modify: l2 (l1.set) parent
   *)
