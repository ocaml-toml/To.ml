%{
(** Header *)
open TypeTo

(** We keep the last group we met, that will prefix all the key incomming *)
let current_group = ref ""

%}

/* OcamlYacc definitions */
%token <bool> BOOL
%token <int> INTEGER
%token <float> FLOAT
%token <string> STRING DATE
%token <string> KEY
%token LBRACK RBRACK EQUAL EOF COMMA

%start toml

%type <TypeTo.toml> toml
%type <unit> group
%type <(string * tomlValue)> keyValue
%type <tomlNodeArray> array_start

%%
/* Grammar rules */
toml:
  group toml { $2 }
  | keyValue toml { let (group,value) = $1 in
                       TypeTo.add $2 ((!current_group^group), value);
                    $2
                  }
  | error toml { $2 }
  | EOF { TypeTo.init () }

group:
  LBRACK KEY RBRACK { current_group := ($2^".") }

keyValue:
    KEY EQUAL value { ($1, $3) }

value:
    BOOL { TBool($1) }
  | INTEGER { TInt($1) }
  | FLOAT { TFloat($1) }
  | STRING { TString($1) }
  | DATE { TDate $1 }
  | LBRACK array_start { TArray($2) }


array_start:
    RBRACK { NodeBool([]) }
  | BOOL array_end(BOOL) { NodeBool($1 :: $2) }
  | INTEGER array_end(INTEGER) { NodeInt($1 :: $2) }
  | FLOAT array_end(FLOAT) { NodeFloat($1 :: $2) }
  | STRING array_end(STRING) { NodeString($1 :: $2) }
  | DATE array_end(DATE) { NodeDate($1 :: $2) }
(*
  | LBRACK array_start RBRACK { NodeArray([$2]) }
 *)

array_end(param):
    COMMA param array_end(param) { $2 :: $3 }
  | COMMA? RBRACK { [] }

%%

