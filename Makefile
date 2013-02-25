
FLAGS := -use-ocamlfind
PKGS :=
INC := -I src

TESTS_FLAGS := $(FLAGS)
TESTS_PKGS := -pkgs ounit
TESTS_INC := -I tests $(INC)

all:
	ocamlbuild $(FLAGS) $(PKGS) $(INC) to.ml.cmxa

test:
	ocamlbuild $(TESTS_FLAGS) $(TESTS_PKGS) $(TESTS_INC) test_ocatoml.native

clean::
	ocamlbuild -clean

