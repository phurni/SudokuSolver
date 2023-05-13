# Soduko solver
# PHI - May 2023

# Global definitions for board and solver
class NoPossibleValueHere < StandardError
end

# Load micro-optparse from local copy. Thanx to https://github.com/florianpilz/micro-optparse
require_relative 'micro-optparse'

# Parse and check command line options
options = Parser.new do |p|
  p.banner = <<~EOS
    Sudoku solver using plugin implementation for the board and the solver.
    Usage: #{$0} [options] <board_file_path>"
    Examples:
      ruby -r./pascal_solver.rb -r./nested_board.rb main.rb ../data/sudoku-1.txt
      ruby -r./pascal_solver.rb -r./nested_board.rb main.rb -p -d 5 -o "ABCDEFGHIJKLMNOPQRSTUVWXY" ../data/alpha-beginner-1.txt
    EOS
  p.option :board_class, ["Specify the class name of the board implementation.", "You still have to `require` it with the `-r` option of `ruby`"], default: "NestedBoard"
  p.option :solver_class, ["Specify the class name of the solver implementation.", "You still have to `require` it with the `-r` option of `ruby`"], default: "PascalSolver"
  p.option :print_initial, "Print the loaded initial board before the solution"
  p.option :dimension, "Inner dimension of the board", default: 3
  p.option :possible_values, ["List of all valid values for one cell.", "(separated by commas if one value is more than one char)"], default: "123456789"
  p.option :free_value, "The value representing free cells of the grid (defaults to ' ')", default: " "
end.process!

board_filepath = ARGV.shift
abort "No board file given!" unless board_filepath

solver_class = Object.const_get(options[:solver_class])
board_class = Object.const_get(options[:board_class])

def from_file(board, filepath)
  value_line_matcher = Regexp.new(board.possible_values.map {|value| Regexp.escape(value.to_s) }.join('|'))
  value_extractor = /(#{value_line_matcher}|#{Regexp.escape(board.free_value)})/

  File.readlines(filepath).filter_map do |line|
    next if line =~ /^\s*#/
    if line.match? value_line_matcher
      line.scan(value_extractor).flatten
    end
  end
end

def print_board(board)
  board.dimension.times do |block_row_index|
    print "+#{'-'*board.dimension}"*board.dimension, "+\n"
    board.dimension.times do |element_row_index|
      print '|'
      board.dimension.times do |block_column_index|
        board.dimension.times do |element_column_index|
          value = board[block_column_index*board.dimension+element_column_index, block_row_index*board.dimension+element_row_index]
          print value == board.free_value ? ' ' : value.to_s
        end
        print '|'
      end
      puts
    end
  end
  print "+#{'-'*board.dimension}"*board.dimension, "+\n\n"
end

board = board_class.new(dimension: options[:dimension], free_value: options[:free_value], possible_values: options[:possible_values].split(options[:possible_values].include?(',') ? ',' : '')) do |board|
  from_file(board, board_filepath)
end

print_board(board) if options[:print_initial]

solver = solver_class.new
final_board = solver.solve(board)

print_board(final_board)
