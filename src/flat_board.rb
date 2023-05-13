require_relative 'sudoku_board'

class FlatBoard < SudokuBoard
  def initialize(**kwargs)
    super(**kwargs)
    @cells = yield(self).flatten
  end

  def initialize_copy(original)
    @cells = original.instance_variable_get(:@cells).clone
  end

  def value_correct_at?(column_index, row_index, value)
    !(row_values(row_index).include?(value) || column_values(column_index).include?(value) || block_values(column_index, row_index).include?(value))
  end

  def [](column_index, row_index)
    @cells[row_index*@column_count + column_index]
  end

  def []=(column_index, row_index, value)
    @cells[row_index*@column_count + column_index] = value
  end

  def each
    @cells.each_with_index {|value, idx| yield idx % @column_count, idx / @column_count, value }
  end

  def row_values(row_index)
    @cells[row_index*@column_count, @column_count]
  end

  def column_values(column_index)
    @cells.each_slice(@column_count).map {|values| values[column_index] }
  end

  def block_values(column_index, row_index)
    top_row_index = (row_index / @dimension) * @dimension
    left_column_index = (column_index / @dimension) * @dimension

    block_rows = @cells[top_row_index*@column_count, @column_count*@dimension]
    block_rows.each_slice(@column_count).flat_map {|values| values[left_column_index, @dimension] }
  end
end
