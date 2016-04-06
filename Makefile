all: clean
	obuild configure
	obuild build

run: all
	./mythtvguide

clean:
	obuild clean

install:
	obuild install
