require_relative 'sudoku_board'

class NestedBoard < SudokuBoard
  def initialize(**kwargs)
    super(**kwargs)
    @rows = yield(self).map(&:clone)
  end

  def initialize_copy(original)
    @rows = original.instance_variable_get(:@rows).map(&:clone)
  end

  def value_correct_at?(column_index, row_index, value)
    !(row_values(row_index).include?(value) || column_values(column_index).include?(value) || block_values(column_index, row_index).include?(value))
  end

  def [](column_index, row_index)
    @rows[row_index][column_index]
  end

  def []=(column_index, row_index, value)
    @rows[row_index][column_index] = value
  end

  def each
    @rows.each_with_index {|row, row_index| row.each_with_index {|value, column_index| yield column_index, row_index, value } }
  end

  def row_values(row_index)
    @rows[row_index]
  end

  def column_values(column_index)
    @rows.map {|row| row[column_index] }
  end

  def block_values(column_index, row_index)
    top_row_index = (row_index / @dimension) * @dimension
    left_column_index = (column_index / @dimension) * @dimension

    @rows[top_row_index, @dimension].flat_map {|row| row[left_column_index, @dimension] }
  end
end
