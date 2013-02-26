%{
(** Header *)
open To

%}

/* OcamlYacc definitions */
%token <int> INTEGER
%token <float> FLOAT
%token <string> STRING
%token <string> KEY
%token <bool> BOOL
%token LBRACK RBRACK EQUAL EOF

%start toml
%type <toml> input
%type <To.Group> group
%type <To.KeyValue> keyValue

%%
/* Grammar rules */
toml:
      group
    | keyValue
  
%%

(* Additionnal ocaml code *) 
