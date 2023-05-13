class BruteForceSolver
  def solve(board)
    new_board = board.clone

    new_board.each_free_cell do |column_index, row_index|
      new_board.possible_values.each do |value|
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
