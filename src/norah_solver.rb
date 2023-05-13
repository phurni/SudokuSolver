class NorahSolver
  def solve(board)
    new_board = board.clone

    # Norah block (TODO)
    # for each block in the grid:
    #   for each free cell in the block:
    #     if there is only one possible value (due to the rules), place it now.

    # Norah ranking
    # count the occurrences of all values in the grid, then try all the possible values in the order of the most found value to the least
    ranked_possible_values = new_board.filter_map {|x,y,v| v if v != new_board.free_value}.tally.sort_by {|value, count| -count}.map(&:first)
    ranked_possible_values |= new_board.possible_values

    new_board.each_free_cell do |column_index, row_index|
      ranked_possible_values.each do |value|
        if new_board.value_correct_at?(column_index, row_index, value)
          new_board[column_index, row_index] = value
          begin
            return solve(new_board)
          rescue NoPossibleValueHere
            new_board[column_index, row_index] = new_board.free_value
          end
        end
      end
      raise NoPossibleValueHere
    end

    new_board
  end
end
