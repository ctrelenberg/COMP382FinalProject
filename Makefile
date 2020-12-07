FLEX_PREPROCESSOR=lex
FLEX_FLAGS=
COMPILER=g++
COMPILER_FLAGS=-std=c++11

all: build

lex:
	$(FLEX_PREPROCESSOR) decaflex.lex $(FLEX_FLAGS)

build: lex
	$(COMPILER) $(COMPILER_FLAGS) lex.yy.cc && rm lex.yy.cc

run: build
	./a.out

.PHONY: clean lex

clean:
	rm lex.yy.cc a.out
