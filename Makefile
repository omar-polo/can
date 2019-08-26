all: main.native

FSTAR_HOME	?= ${HOME}/build/fstar
FSTAR		?= fstar.exe --use_hints --record_hints ${OTHERFLAGS}

include ${FSTAR_HOME}/examples/Makefile.include

FSTAR_SRC	= $(wildcard src/*.fst)
OCAML_SRC	= $(wildcard ml/*.ml)

OUTPUT_DIR	= _output

# ML_FILES	= $(subst src,${OUTPUT_DIR},$(subst .fst,.ml,${FSTAR_SRC}))

OC	?= OCAMLPATH=${FSTAR_HOME}/bin ocamlbuild -use-ocamlfind -pkg fstarlib -I ${OUTPUT_DIR}

OCAMLDEPS	= str.cma unix.cma $(wildcard ml/*.mli)

.PHONY: fstar-code clean all debug

all: main.native README.txt

README.txt: Can.3
	man -T ascii -O 'width=72' -l Can.3 \
		| col -b | sed -e '1d' -e '$$d' \
		| pr -h Can > README.txt

fstar-code:
	${FSTAR} ${FSTAR_DEFAULT_ARGS} \
		--odir ${OUTPUT_DIR} \
		--codegen OCaml \
		src/*.fst
# $(subst ${OUTPUT_DIR},src,$(subst .ml,.fst,$@))

_tags:
	echo "<ml>: traverse" > $@
	echo "<${OUTPUT_DIR}>: traverse" >> $@
	echo "<${OUTPUT_DIR}/c>: -traverse" >> $@

${OUTPUT_DIR}:
	mkdir ${OUTPUT_DIR}

main.native: ${OUTPUT_DIR} _tags fstar-code ${OCAML_SRC}
	${OC} ml/main.native

# temporary -- I still don't use the F* code in ocaml
main: ${OCAML_SRC}
	ocamlc -o main ${OCAMLDEPS} ml/operation.ml ml/grammar.ml ml/main.ml

# ocamlc -o main ${OCAMLDEPS} ml/operation.ml ml/grammar.ml ml/main.ml

clean:
	rm -rf ${OUTPUT_DIR}
	rm _tags

# debug the makefile
debug:
	@echo OTHERFLAGS ${OTHERFLAGS}
	@echo ML_FILES ${ML_FILES}
	@echo FSTAR ${FSTAR_EXE}
	@echo FSTAR_HOME ${FSTAR_HOME}
	@echo FSTAR_SRC ${FSTAR_HOME}
	@echo OCAML_SRC ${FSTAR_HOME}
	@echo OC ${OC}
