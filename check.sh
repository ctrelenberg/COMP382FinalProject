#!/bin/bash

# A simple bash script to check that the output of the program is correct for a test case.
./a.out --canonical < "testcases/dev/$1.decaf" > temp.tmp

# diff temp.tmp "testcases/solutions/dev/$1.out" | cat -v -e -t
diff -Z temp.tmp "testcases/solutions/dev/$1.out" | cat -v -e -t
