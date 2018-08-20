all: clean
	dune build bin/mythtvguide.exe

run: all
	dune exec bin/mythtvguide.exe

clean:
	dune clean

install:
	dune install
