all:
	dune build @install

test:
	dune runtest --force

clean:
	dune clean

doc:
	dune build @doc
