# LL(1) Parse Table Generator 

**Tasks**

1. Remove Left Recursion
2. Do Left Factoring
3. Find the LL(1) parse table. (Display this in a convenient human readable form on the screen).
4. Thus, declare whether the input CFG is LL(1) or not (if not, give the reason also).

## Command Line Arguments for running the code

1. flex Group34.l
2. g++ lex.yy.c -std=gnu++0x
3.  .\a.exe input.txt 

**Note**

1. input.txt should be in the same directory in which Group34.l is
2. You can give any of the testcases as input file by writing .\a.exe followed by the filename.txt

## About the code

1. \# is used for epsilon throughout the code.
2. Instead of introducing new variables like S' or X' while removing recursion or factoring the grammar,
      Z gets introduced in the grammar(Alphabets are followed backwards from Z),
      If required then Y will get introduced.
3. Reading the input file,Task 1 and Task 2 were completed in C
      Task 3 and Task 4 were completed in C++
4. For task 1 our code also supports removal of INDIRECT Left Recursion,
      you can verify with indirect_testcase.txt

#### Note

1. For the input.txt, separate using ->
      instead of any arrow symbol or character
2.  Use | to write all the productions starting from the same non-terminal.