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
%token LBRACK RBRACK EQUAL EOF COMMA

%start toml
%type <TypeTo.toml> toml
%type <unit> group
%type <(string * tomlValue)> keyValue
%type <tomlNodeArray> array

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
  | LBRACK array RBRACK { TArray($2) }


array:
  /* Empty */ { NodeBool([]) }
  | separated_nonempty_list(COMMA, BOOL) COMMA? { NodeBool($1) }
  | separated_nonempty_list(COMMA, INTEGER) COMMA? { NodeInt($1) }
  | separated_nonempty_list(COMMA, FLOAT) COMMA? { NodeFloat($1) }
  | separated_nonempty_list(COMMA, STRING) COMMA? { NodeString($1) }
  | LBRACK RBRACK { NodeArray([NodeBool([])]) }
  | LBRACK array RBRACK { NodeArray([$2]) }

%%

