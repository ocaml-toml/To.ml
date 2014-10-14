FLAGS=-use-ocamlfind -yaccflags --explain -use-menhir -package str
INC=src

TESTS_FLAGS=$(FLAGS)
TESTS_PKGS=oUnit
TESTS_INC=$(INC),tests
TEST_FILES=\
parser_test.ml \
example.ml \
hard_example.ml \
helper_test.ml

COVERAGE_FLAGS=$(TESTS_FLAGS)
COVERAGE_TAGS=package\(bisect\),syntax\(camlp4o\),syntax\(bisect_pp\)
COVERAGE_INC=$(TESTS_INC)

LIB_FILES=toml.a toml.cmxa toml.cma toml.cmi

build: $(LIB_FILES)

install:
	ocamlfind install toml META $(addprefix _build/src/, $(LIB_FILES))

uninstall:
	ocamlfind remove toml

$(LIB_FILES):
	ocamlbuild $(FLAGS) -I $(INC) $@

test: $(TEST_FILES:.ml=.native)
	@echo '*******************************************************************'
	@./parser_test.native
	@./helper_test.native
	@./example.native < tests/example.toml
	@./hard_example.native < tests/hard_example.toml


$(TEST_FILES:.ml=.native):
	ocamlbuild $(TESTS_FLAGS) -pkgs $(TESTS_PKGS) -Is $(TESTS_INC) $@

coverage:
	ocamlbuild $(COVERAGE_FLAGS) -pkgs $(TESTS_PKGS) -tags $(COVERAGE_TAGS) -Is $(COVERAGE_INC) $(TEST_FILES:.ml=.byte)
	@BISECT_FILE=_build/coverage ./parser_test.byte
	@BISECT_FILE=_build/coverage ./helper_test.byte
	@BISECT_FILE=_build/coverage ./example.byte < tests/example.toml
	@BISECT_FILE=_build/coverage ./hard_example.byte < tests/hard_example.toml

doc:
	ocamlbuild -I src toml.docdir/index.html

report: coverage
	cd _build && bisect-report -verbose -html report coverage*.out

clean:
	ocamlbuild -clean
