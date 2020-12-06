FLEX_PREPROCESSOR=lex
FLEX_FLAGS=
COMPILER=g++
COMPILER_FLAGS=-std=c++11

all: build

lex.yy.cc:
	$(FLEX_PREPROCESSOR) decaflex.lex $(FLEX_FLAGS)

build: lex.yy.cc
	$(COMPILER) $(COMPILER_FLAGS) lex.yy.cc

run: build
	./a.out

.PHONY: clean

clean:
	rm lex.yy.cc a.out
