all: build test
all-cconv: build-cconv test

build:
	dune build toml.install

build-cconv:
	dune build toml-cconv.install

test:
	dune runtest --force

clean:
	dune clean

install-dependencies:
	opam install --yes menhir cconv bisect oUnit odoc

install: build
	dune install toml

install-cconv: build-cconv
	dune install toml-cconv

doc:
	dune build @doc
