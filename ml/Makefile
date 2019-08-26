OCAMLC	?= ocamlc
OCAMLOPT = -I +threads

.PHONY: all clean

.SUFFIXES: .ml .cmo

all: main

# compile both the .ml and the .mli files
.ml.cmo:
	[ -f $<i ] && ${OCAMLC} ${OCAMLOPT} -c $<i || true
	${OCAMLC} ${OCAMLOPT} -c $<

main: $(wildcard *.ml) operation.cmo grammar.cmo main.cmo
	${OCAMLC} ${OCAMLOPT} -o main unix.cma threads.cma str.cma operation.cmo grammar.cmo main.cmo

clean:
	rm -f *.cmo *.cmi
