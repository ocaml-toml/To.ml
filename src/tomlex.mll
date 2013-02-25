{
 open Parsetoml
}

let t_white   = ['\09' '\20']
(** Tab char or space char *)
let t_eol     = ('\n'|'\r'|"\r\n")
(** Cross platform end of lines *)
let t_blank   = (t_white|t_eol)
(** Blank characters as specified by the ref *)
let t_digit   = ['0'-'9']
let t_int     = -?t_digit+
let t_float   = -?t_digit+'.'t_digit+
(** digits are needed in both side of the dot *)
let t_bool    = ("true"|"false")
(** booleans are full undercase *)
let t_key     = ([^t_blank]|[^t_blank].*[^t_blank])
(** keys begins with non blank char and end with the first blank *)

(* TODO datetime *)

rule tomlex lexbuf = parse
  | t_white+ { tomlex rexbuf }
  | t_eol { tomlex rexbuf }
  | t_int as value   { INTEGER (int_of_string value) }
  | t_float as value { FLOAT (float_of_int value) }
  | t_bool as value  {match value with
                     | "true" -> BOOL (true)
                     | "false" -> BOOL (false)
                     | _ -> failwith("Shit happens in lexer, really")
                       (* if fired, ocamllex have big problems *)
  }
  | '=' { EQUAL }
  | '[' { LBRACK }
  | ']' { RBRACK }
  | '"' { stringify (Buffer.create 13) lexbuf }
  | '#' { let _ = comment lexbuf in (); tomlex rexbuf }
  | t_key as value { KEY (value) }
  | eof   {}

and stringify buff lexbuf = parse
  (* escape everything *)
  | '\\'. as value { Buffer.add_string buff value; stringify buff lexbuf }
  (* no unterminated strings *)
  | eof  { failwith("Unterminated string in file") } (* TODO line handling *)
  | '"'  { STRING(Buffer.contents buff) }
  | _ as c { Buffer.add_char buff c; stringify buff lexbuf }

and comment lexbuf = parse
  | (t_eol|eof) { () }
  | _ { comment lexbuf }


{}