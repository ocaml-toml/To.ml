(** Reads the toml file you give in argument and parse it
  * Then print it
  *)

open Pprint

let _ =
  let input = (open_in Sys.argv.(1)) in
    let buff = Buffer.create 100 in
    try
      while true
      do
        Buffer.add_string buff ((input_line input)^"\n");
      done
    with End_of_file -> print (To.parse (Buffer.contents buff))
