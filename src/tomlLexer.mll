{
 open TomlParser
 open Lexing

 let update_loc lexbuf =
   let pos = lexbuf.lex_curr_p in
   lexbuf.lex_curr_p <- { pos with
     pos_lnum = pos.pos_lnum + 1;
     pos_bol = pos.pos_cnum;
   }
}

let t_white   = ['\t' ' ']
(** Tab char or space char *)
let t_eol     = '\n'|'\r'|"\r\n"
(** Cross platform end of lines *)
let t_blank   = (t_white|t_eol)
(** Blank characters as specified by the ref *)
let t_digit   = ['0'-'9']
let t_int     = ['-''+']? t_digit+
let t_frac    = '.' t_digit+
let t_exp     = ['E''e'] t_int
let t_float   = t_int ((t_frac t_exp) | t_frac | t_exp)
let t_bool    = ("true"|"false")
(** booleans are full undercase *)
let t_key     = [^ '\t' '\n' ' ' '\r' '"' '=' '[' ',' ']' '#']+
(** keys begins with non blank char and end with the first blank *)

let t_date    = (t_digit t_digit t_digit t_digit as year)
                '-' (t_digit t_digit as mon)
                '-' (t_digit t_digit as mday)
                ['T' 't'] (t_digit t_digit as hour)
                ':' (t_digit t_digit as min)
                ':' (t_digit t_digit ('.' t_digit+)? as sec)
                (['Z' 'z'] | (['+' '-'] t_digit t_digit ':' t_digit t_digit)
		 as offset)
(** RFC 3339 date of form 1979-05-27T07:32:00.42+00:00 *)

let t_escape  =  '\\' ['b' 't' 'n' 'f' 'r' '"' '/' '\\']
let t_alpha   = ['A'-'Z' 'a'-'z']
let t_alphanum= t_alpha | t_digit
let t_unicode = t_alphanum t_alphanum t_alphanum t_alphanum

rule tomlex = parse
  | t_int as value   { let value =
			 if value.[0] = '+'
			 then String.sub value 1 (String.length value - 1)
			 else value in
		       INTEGER (int_of_string value) }
  | t_float as value { FLOAT (float_of_string value) }
  | t_bool as value  { BOOL (bool_of_string value) }

  (* FIXME: Update with RFC 3339 *)
  | t_date { DATE { Unix.tm_sec = int_of_string sec;
                    Unix.tm_min = int_of_string min;
                    Unix.tm_hour = int_of_string hour;
                    Unix.tm_mday = int_of_string mday;
                    Unix.tm_mon = int_of_string mon - 1;
                    Unix.tm_year = int_of_string year - 1900;
                    Unix.tm_wday = (-1);
                    Unix.tm_yday = (-1);
                    Unix.tm_isdst = true (* ??? *)
            } }
  | t_white+ { tomlex lexbuf }
  | t_eol+ { update_loc lexbuf;tomlex lexbuf }
  | '=' { EQUAL }
  | '[' { LBRACK }
  | ']' { RBRACK }
  | '"' { stringify (Buffer.create 13) lexbuf }
  | ',' { COMMA }
  | '#' (_ # [ '\n' '\r' ] )* { tomlex lexbuf }
  | t_key as value { KEY (value) }
  | eof   { EOF }

and stringify buff = parse
  | t_escape as value
    { Buffer.add_string buff (Scanf.unescaped value); stringify buff lexbuf }
  | "\\u" (t_unicode as u)
    { Buffer.add_string buff (TomlUnicode.to_utf8 u); stringify buff lexbuf }
  | '\\' { failwith "Forbidden escaped char" }
  (* no unterminated strings *)
  | eof  { failwith "Unterminated string" }
  | '"'  { STRING (Buffer.contents buff) }
  | t_eol as eol { update_loc lexbuf; Buffer.add_string buff eol; stringify buff lexbuf }
  | _ as c { Buffer.add_char buff c; stringify buff lexbuf }

{}
