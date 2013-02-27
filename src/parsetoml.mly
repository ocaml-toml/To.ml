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
%token <string> STRING
%token <string> KEY
%token LBRACK RBRACK EQUAL EOF COLON

%start toml
%type <TypeTo.toml> toml
%type <unit> group
%type <(string * tomlValue)> keyValue
%type <tomlNodeArray> array

%type <bool list> bool_chunk
%type <int list> int_chunk
%type <float list> float_chunk
%type <string list> string_chunk

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
    KEY EQUAL BOOL { ($1, TBool($3)) }
  | KEY EQUAL INTEGER { ($1, TInt($3)) }
  | KEY EQUAL FLOAT { ($1, TFloat($3)) }
  | KEY EQUAL STRING { ($1, TString($3)) }
  | KEY EQUAL LBRACK array RBRACK { ($1, TArray($4)) }

array:
  /* Empty */ { NodeBool([]) }
  | bool_chunk { NodeBool($1) }
  | int_chunk  { NodeInt($1) }
  | float_chunk { NodeFloat($1) }
  | string_chunk { NodeString($1) }
  | LBRACK RBRACK { NodeArray([NodeBool([])]) }
  | LBRACK array RBRACK { NodeArray([$2]) }
  | LBRACK array_chunk { NodeArray($2) }

array_chunk:
    array RBRACK { [$1] }
  | array COLON array_chunk { $1::$3 }

bool_chunk:
    BOOL { [$1] }
  | BOOL COLON bool_chunk { $1::$3 }

int_chunk:
    INTEGER { [$1] }
  | INTEGER COLON int_chunk { $1::$3 }

float_chunk:
    FLOAT { [$1] }
  | FLOAT COLON float_chunk { $1::$3 }

string_chunk:
    STRING { [$1] }
  | STRING COLON string_chunk { $1::$3 }

%%

