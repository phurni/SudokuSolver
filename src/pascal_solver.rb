class PascalSolver
  def solve(board)
    new_board = board.clone

    # Create a board of possible candidates
    # Each cell of the board will contain all the possible value candidates by removing row, column and block values.
    # Then instead of linear browsing in each_free_cell, we iterate from the free cell with the less candidates count. BTW, it's no more needed to try every possible_values but only the computed candidates.
    candidates = new_board.each_free_cell.map do |column_index, row_index|
      [column_index, row_index, new_board.possible_values.select {|value| new_board.value_correct_at?(column_index, row_index, value) }]
    end

    candidates.sort_by {|_, _, values| values.size }.each do |column_index, row_index, possible_values|
      possible_values.each do |value|
        new_board[column_index, row_index] = value
        begin
          return solve(new_board)
        rescue NoPossibleValueHere
          new_board[column_index, row_index] = new_board.free_value
        end
      end
      raise NoPossibleValueHere
    end

    new_board
  end
end
