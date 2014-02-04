FLAGS=-use-ocamlfind -yaccflags --explain -use-menhir -package str
INC=src

TESTS_FLAGS=$(FLAGS)
TESTS_PKGS=oUnit
TESTS_INC=$(INC),tests

COVERAGE_FLAGS=$(TESTS_FLAGS)
COVERAGE_TAGS=package\(bisect\),syntax\(camlp4o\),syntax\(bisect_pp\)
COVERAGE_INC=$(TESTS_INC)

build: toml.cmxa toml.cma

install:
	ocamlfind install toml META _build/src/toml.cmxa _build/src/toml.cma _build/src/toml.cmi

uninstall:
	ocamlfind remove toml

toml.cmxa toml.cma:
	ocamlbuild $(FLAGS) -I $(INC) $@

test: test_toml.native official_example.native official_hard_example.native
	@echo '*******************************************************************'
	@./test_toml.native
	@./official_example.native
	@./official_hard_example.native

test_toml.native official_example.native official_hard_example.native:
	ocamlbuild $(TESTS_FLAGS) -pkgs $(TESTS_PKGS) -Is $(TESTS_INC) $@

coverage:
	ocamlbuild $(COVERAGE_FLAGS) -pkgs $(TESTS_PKGS) -tags $(COVERAGE_TAGS) -Is $(COVERAGE_INC) test_toml.byte official_example.byte official_hard_example.byte
	BISECT_FILE=_build/coverage ./test_toml.byte
	BISECT_FILE=_build/coverage ./official_example.byte
	BISECT_FILE=_build/coverage ./official_hard_example.byte
	cd _build && bisect-report -verbose -html report coverage*.out

clean:
	ocamlbuild -clean

