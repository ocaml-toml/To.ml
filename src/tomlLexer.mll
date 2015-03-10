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

  | t_date { let (off_hour, off_min) = match offset with
	       | "Z" | "z" -> (0, 0)
	       | offset -> let sign = if offset.[0] = '+'
				      then (fun x -> 0 + int_of_string x)
				      else (fun x -> 0 - int_of_string x) in
			   (sign (String.sub offset 1 2),
			    sign (String.sub offset 4 2)) in
	     DATE ( Unix.mktime
		      { Unix.tm_sec = int_of_float (float_of_string sec);
			Unix.tm_min = int_of_string min + off_min;
			Unix.tm_hour = int_of_string hour + off_hour;
			Unix.tm_mday = int_of_string mday;
			Unix.tm_mon = int_of_string mon - 1;
			Unix.tm_year = int_of_string year - 1900;
			Unix.tm_wday = 0;
			Unix.tm_yday = 0;
			Unix.tm_isdst = false }
		    |> snd )
	   }
  | t_white+ { tomlex lexbuf }
  | t_eol { update_loc lexbuf;tomlex lexbuf }
  | '=' { EQUAL }
  | '[' { LBRACK }
  | ']' { RBRACK }
  | '"' '"' '"' (t_eol? as eol) {
	  if eol <> "" then update_loc lexbuf ;
	  multiline_string (Buffer.create 13) lexbuf }
  | '"' { basic_string (Buffer.create 13) lexbuf }
  | ',' { COMMA }
  | '#' (_ # [ '\n' '\r' ] )* { tomlex lexbuf }
  | t_key as value { KEY (value) }
  | eof   { EOF }

and basic_string buff = parse
  | '"'  { STRING (Buffer.contents buff) }
  | ""   { string_common basic_string buff lexbuf }

and multiline_string buff = parse
  | '"' '"' '"' { STRING (Buffer.contents buff) }
  | '\\' t_eol { update_loc lexbuf;
		 multiline_string_trim buff lexbuf }
  | t_eol as eol { update_loc lexbuf;
		   Buffer.add_string buff eol;
		   multiline_string buff lexbuf }
  | "" { string_common multiline_string buff lexbuf }

and multiline_string_trim buff = parse
  | t_eol { update_loc lexbuf;
	    multiline_string_trim buff lexbuf }
  | t_white { multiline_string_trim buff lexbuf }
  | "" { multiline_string buff lexbuf }

and string_common next buff = parse
  | t_escape as value { Buffer.add_string buff (Scanf.unescaped value);
			next buff lexbuf }
  | "\\u" (t_unicode as u)
    { Buffer.add_string buff (TomlUnicode.to_utf8 u);
      next buff lexbuf }
  | '\\' { failwith "Forbidden escaped char" }
  | eof  { failwith "Unterminated string" }
  | _ as c { let code = Char.code c in
	     if code < 16
	     then failwith "Control characters (U+0000 to U+001F) \
			    must be escaped";
	     Buffer.add_char buff c;
	     next buff lexbuf }


{}
