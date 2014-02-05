FLAGS=-use-ocamlfind -yaccflags --explain -use-menhir -package str
INC=src

TESTS_FLAGS=$(FLAGS)
TESTS_PKGS=oUnit
TESTS_INC=$(INC),tests
TEST_FILES=\
parser_test.ml \
official_example.ml \
official_hard_example.ml \
helper_test.ml

COVERAGE_FLAGS=$(TESTS_FLAGS)
COVERAGE_TAGS=package\(bisect\),syntax\(camlp4o\),syntax\(bisect_pp\)
COVERAGE_INC=$(TESTS_INC)

LIB_FILES=\
toml.cmxa \
toml.cma \
toml.cmi \
tomlType.cmi

build: toml.cmxa toml.cma

install:
	ocamlfind install toml META $(addprefix _build/src/, $(LIB_FILES))

#_build/src/toml.cmxa _build/src/toml.cma _build/src/toml.cmi 

uninstall:
	ocamlfind remove toml

toml.cmxa toml.cma:
	ocamlbuild $(FLAGS) -I $(INC) $@

test: $(TEST_FILES:.ml=.native)
	@echo '*******************************************************************'
	@$(foreach file, $^, ./$(file);)

$(TEST_FILES:.ml=.native):
	ocamlbuild $(TESTS_FLAGS) -pkgs $(TESTS_PKGS) -Is $(TESTS_INC) $@

coverage:
	ocamlbuild $(COVERAGE_FLAGS) -pkgs $(TESTS_PKGS) -tags $(COVERAGE_TAGS) -Is $(COVERAGE_INC) $(TEST_FILES:.ml=.byte)
	@$(foreach file, $(TEST_FILES:.ml=.byte), BISECT_FILE=_build/coverage ./$(file);)
	cd _build && bisect-report -verbose -html report coverage*.out

clean:
	ocamlbuild -clean

