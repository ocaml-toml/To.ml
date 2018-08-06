all:
	jbuilder build @install

test:
	jbuilder runtest --force

clean:
	jbuilder clean

doc:
	jbuilder build @doc
