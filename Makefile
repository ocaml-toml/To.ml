build:
	dune build @install -p toml

build-cconv:
	dune build @install -p toml-cconv

test:
	dune runtest --force

clean:
	dune clean

install: build
	dune install -p toml

install-cconv: build-cconv
	dune install -p toml-cconv

doc:
	dune build @doc
