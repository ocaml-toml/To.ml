
FLAGS := -use-ocamlfind -yaccflags --explain -use-menhir -lib str
PKGS :=
INC := -I src

TESTS_FLAGS := $(FLAGS)
TESTS_PKGS := -pkgs oUnit
TESTS_INC := -I tests $(INC)

all: to.ml.cmxa

to.ml.cmxa:
	ocamlbuild $(FLAGS) $(PKGS) $(INC) to.ml.cmxa

test: test_toml.native
	@echo '*******************************************************************'
	@./test_toml.native

test_toml.native:
	ocamlbuild $(TESTS_FLAGS) $(TESTS_PKGS) $(TESTS_INC) test_toml.native


clean::
	ocamlbuild -clean

