{
 open Parsetoml
}

let white   = ['\09' '\20']
(** Tab char or space char *)
let eol     = ('\n'|'\r'|"\r\n")
(** Cross platform end of lines *)
let blank   = (white|eol)
(** Blank characters as specified by the ref *)
let digit   = ['0'-'9']
let int     = -?digit+
let float   = -?digit+'.'digit+
(** digits are needed in both side of the dot *)
let bool    = ("true"|"false")
(** booleans are full undercase *)
let key     = ([^blank]|[^blank].*[^blank])
(** keys begins with non blank char and end with the first blank *)

(* TODO datetime *)

rule tomlex lexbuf = parse
  | white+ { tomlex rexbuf }
  | eol { tomlex rexbuf }
  | int as value   { INTEGER (int_of_string value) }
  | float as value { FLOAT (float_of_int value) }
  | bool as value  {match value with
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
  | key as value { KEY (value) }
  | eof   {}

and stringify buff lexbuf = parse
  (* escape everything *)
  | '\\'. as value { Buffer.add_string buff value; stringify buff lexbuf }
  (* no unterminated strings *)
  | eof  { failwith("Unterminated string in file") } (* TODO line handling *)
  | '"'  { STRING(Buffer.contents buff) }
  | _ as c { Buffer.add_char buff c; stringify buff lexbuf }

and comment lexbuf = parse
  | (eol|eof) { () }
  | _ { comment }


{}