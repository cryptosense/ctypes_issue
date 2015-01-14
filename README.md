# Requires
```
opam switch 4.02.1+PIC
opam install ctypes
```

# How to test

make all

# Files

- main.ml => an ocaml program that loads a shared lib using ctypes.
- shared_lib_decl.ml => a shared library that exposes two test functions.
