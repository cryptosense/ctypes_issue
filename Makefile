
all: clean test

exe:
	ocamlbuild -use-ocamlfind -package ctypes,ctypes.foreign main.native

dll:
	ocamlbuild -use-ocamlfind -package ctypes,ctypes.foreign,ctypes.stubs  dllshared_lib.so
clean:
	ocamlbuild -clean

test:exe dll
	./main.native _build/dllshared_lib.so
