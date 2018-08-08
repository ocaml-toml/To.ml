build:
	dune build toml.install

build-cconv:
	dune build toml-cconv.install

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
