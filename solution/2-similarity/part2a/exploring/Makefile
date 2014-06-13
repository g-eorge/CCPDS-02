PATH  := $(PATH)
SHELL := /bin/bash

cpp	:= $(wildcard *.cpp)
exe	:= $(cpp:%.cpp=%)

.PHONY: all clean

all: $(exe)

similarity: similarity.cpp

part2a: part2a.cpp

$(exe):
	clang++ -std=c++11 -stdlib=libc++ -o $@ $<

clean:
	@ rm -f *.out $(exe)