all:
	jbuilder build @install

test:
	jbuilder runtest

clean:
	jbuilder clean

doc:
	jbuilder build @doc
