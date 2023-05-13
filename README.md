# Sudoku Solver

A sudoku solver with multiple implementations for the board and the solver intended to be
a developer playground for experiments. Notably to compare speed and memory usage among the implementations.

The implementation are flexible and may resolve sudoku or variants with your own dimension and values.
So _alphadoku_ may be solved without any change in code.

It is licensed under the [MIT License](http://opensource.org/licenses/MIT), so feel free
to fork it and run your own experiments.

Copyright (C) Pascal Hurni <[https://github.com/phurni](https://github.com/phurni)>

## Usage

Have a grid ready in a text file, only the lines with valid possible values are part of the grid
so that you can add separators (like the output solution).

Then go to the `src` directory and run it like:

    ruby -r./pascal_solver.rb -r./nested_board.rb main.rb ../data/sudoku-1.txt

You may specify more options, choosing other implementations:

    ruby -r./norah_solver.rb -r./flat_board.rb main.rb -b FlatBoard -s NorahSolver ../data/sudoku-1.txt

Other options to control the dimension and values:

    ruby -r./pascal_solver.rb -r./nested_board.rb main.rb -p -d 5 -o "ABCDEFGHIJKLMNOPQRSTUVWXY" ../data/alpha-beginner-1.txt

## Profiling

To compare implementations we have to use profiling tools, in ruby land there is the
[ruby-prof](https://rubygems.org/gems/ruby-prof) gem.

Let's run and profile with:

    ruby-prof -r./norah_solver.rb -r./flat_board.rb main.rb -- -b FlatBoard -s NorahSolver ../data/sudoku-1.txt

Here is a stripped output of `ruby-prof`:

```
Measure Mode: wall_time
Total: 0.816092
Sort by: self_time

 %self      total      self      wait     child     calls  name
 58.60      0.811     0.478     0.000     0.333    45714  *Array#each
  4.68      0.292     0.038     0.000     0.254    50009   FlatBoard#value_correct_at?
  ...
  1.40      0.810     0.011     0.000     0.799     5574  *NorahSolver#solve
```

We can see that the number of recursive calls of `NorahSolver#solve` is 5574 and the wall clock time is 0.8 seconds.

Run the same grid with the `PascalSolver`:

    ruby-prof -r./pascal_solver.rb -r./flat_board.rb main.rb -- -b FlatBoard -s PascalSolver ../data/sudoku-1.txt

Output:

```
Measure Mode: wall_time
Total: 1.268745
Sort by: self_time

 %self      total      self      wait     child     calls  name
 38.27      1.265     0.486     0.000     0.780   116642  *Array#each
 12.46      0.670     0.158     0.000     0.512   230272   Enumerable#each_slice
  9.10      1.179     0.115     0.000     1.064   117999   FlatBoard#value_correct_at?
  6.67      0.085     0.085     0.000     0.000   233149   Array#include?
  ...
  0.05      1.265     0.001     0.000     1.264      367  *PascalSolver#solve
```

This time the number of recursive calls of `PascalSolver#solve` is only 367 **but** the wall clock time
raised to 1.2 seconds.

Run again keeping the `PascalSolver` but using the `NestedBoard` instead of the `FlatBoard`:

    ruby-prof -r./pascal_solver.rb -r./nested_board.rb main.rb -- -s PascalSolver ../data/sudoku-1.txt

Output:

```
Measure Mode: wall_time
Total: 0.600730
Sort by: self_time

 %self      total      self      wait     child     calls  name
 20.43      0.126     0.123     0.000     0.003    71718   Array#map
 16.79      0.516     0.101     0.000     0.415   117999   NestedBoard#value_correct_at?
 13.31      0.598     0.080     0.000     0.518    48596  *Array#each
 12.84      0.077     0.077     0.000     0.000   233149   Array#include?
  ...
  0.11      0.597     0.001     0.000     0.597      367  *PascalSolver#solve
```

Without surprise the number of recursive calls of `PascalSolver#solve` is still 367 **but** the wall clock time
dropped to 0.6 seconds.

