{
 open Parsetoml
}

let t_white   = ['\t' ' ']
(** Tab char or space char *)
let t_eol     = ('\n'|'\r'|"\r\n")
(** Cross platform end of lines *)
let t_blank   = (t_white|t_eol)
(** Blank characters as specified by the ref *)
let t_digit   = ['0'-'9']
let t_int     = '-'?t_digit+
let t_float   = '-'?t_digit+'.'t_digit+
(** digits are needed in both side of the dot *)
let t_bool    = ("true"|"false")
(** booleans are full undercase *)
let t_key     = [^ '\t' '\n' ' ' '\r' '"' '=' '[' ',' ']']+
(** keys begins with non blank char and end with the first blank *)
(* very ugly, beark ! But how doing it right in ocamllex ? *)
let t_date    = ['0'-'9']['0'-'9']['0'-'9']['0'-'9']'-'['0'-'9']['0'-'9']'-'['0'-'9']['0'-'9']'T'['0'-'9']['0'-'9']':'['0'-'9']['0'-'9']':'['0'-'9']['0'-'9']'Z'
(** ISO8601 date of form 1979-05-27T07:32:00Z *)

(* TODO datetime *)

rule tomlex = parse
  | t_date as value { STRING value }
  | t_int as value   { INTEGER (int_of_string value) }
  | t_float as value { FLOAT (float_of_string value) }
  | t_bool as value  { BOOL (bool_of_string value) }
  | t_white+ { tomlex lexbuf }
  | t_eol { tomlex lexbuf }
  | '=' { EQUAL }
  | '[' { LBRACK }
  | ']' { RBRACK }
  | '"' { stringify (Buffer.create 13) lexbuf }
  | ',' { COMMA }
  | '#' { comment lexbuf }
  | t_key as value { KEY (value) }
  | eof   { EOF }

and stringify buff = parse
  (* escape everything *)
  | '\\'_ as value { Buffer.add_string buff value; stringify buff lexbuf }
  (* no unterminated strings *)
  | eof  { failwith("Unterminated string in file") } (* TODO line handling *)
  | '"'  { STRING (Buffer.contents buff) }
  | _ as c { Buffer.add_char buff c; stringify buff lexbuf }

and comment = parse
  | t_eol { tomlex lexbuf }
  | eof { EOF }
  | _ { comment lexbuf }


{}
