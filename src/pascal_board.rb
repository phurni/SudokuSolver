require_relative 'sudoku_board'

# Observation: the board method called the most is `value_correct_at?`, this sounds sensible because
# there's a lot of tries. How can we reduce that?
#
# To reduce the impact of `value_correct_at?` we should find a way to avoid browsing each rows, columns
# and blocks. Let's track if a particular value is part of every row, column and block and in O(1) please.
#
# The idea is to pack the currently used values of each block (row or column) in a single value.
# This is possible by using a bitfield as the value. Each value (from 1 to 9) is simply the bit set at its
# position (1 to 9), so we can OR them together in a single Integer. Even for alphadoku this is possible
# because we use 25 bits which easily fits even in a 32bit world.
#
# Each time we set a value in the board (with `[]=`), we update the tracking of their respecting row, column
# and block, each in O(1). 

class PascalBoard < SudokuBoard
  def initialize(**kwargs)
    super(**kwargs)

    # Transform the external values to our internal bitfield representation
    @external_free_value = @free_value
    @external_possible_values = @possible_values
    @free_value = 0
    @possible_values = @possible_values.map {|value| 1 << (@external_possible_values.index(value) + 1) }

    # Here are the 3 arrays that tracks the used values.
    @rows = Array.new(@row_count, 0)
    @columns = Array.new(@column_count, 0)
    @blocks = Array.new(@column_count, 0) # there's no @block_count but it should always be dimension**2

    # We still need to track the values we placed in the grid to let the external world get that grid.
    # We also track every free cell to speed up its iteration.
    # Both of these data structures should be accessed in O(1), so we use a dictionary with the key being
    # the flat index of the board.
    @values = Hash.new(@free_value)
    @free_cells = Hash.new(false)

    yield(self).each_with_index do |row, row_index|
      row.each_with_index do |read_value, column_index|
        if read_value == @external_free_value
          @free_cells[row_index*@column_count + column_index] = true
        else
          value = 1 << (@external_possible_values.index(read_value) + 1)
          @values[row_index*@column_count + column_index] = value
          @rows[row_index] |= value
          @columns[column_index] |= value
          @blocks[(row_index / @dimension)*@dimension + column_index / @dimension] |= value
        end
      end
    end
  end

  def initialize_copy(original)
    @rows = original.instance_variable_get(:@rows).dup
    @columns = original.instance_variable_get(:@columns).dup
    @blocks = original.instance_variable_get(:@blocks).dup

    @values = original.instance_variable_get(:@values).dup
    @free_cells = original.instance_variable_get(:@free_cells).dup
  end

  def value_correct_at?(column_index, row_index, value)
    # This is O(3)
    ((@rows[row_index] & value) == 0) && ((@columns[column_index] & value) == 0) && ((@blocks[(row_index / @dimension)*@dimension + column_index / @dimension] & value) == 0)
  end

  def [](column_index, row_index)
    @values[row_index*@column_count + column_index]
  end

  def []=(column_index, row_index, value)
    flat_index = row_index*@column_count + column_index
    if value == @free_value
      previous_value = ~self[column_index, row_index]
      @rows[row_index] &= previous_value
      @columns[column_index] &= previous_value
      @blocks[(row_index / @dimension)*@dimension + column_index / @dimension] &= previous_value

      @values[flat_index] = value
      @free_cells[flat_index] = true
    else
      @rows[row_index] |= value
      @columns[column_index] |= value
      @blocks[(row_index / @dimension)*@dimension + column_index / @dimension] |= value

      @values[flat_index] = value
      @free_cells.delete(flat_index)
    end
  end

  # Override directly `each_free_cell` because we don't need to iterate all the cells to know
  # which are free, we have an internal state that matches exactly that list.
  def each_free_cell
    return to_enum(:each_free_cell) unless block_given?

    @free_cells.keys.each do |flat_index|
      yield flat_index % @column_count, flat_index / @column_count
    end
  end

  def to_external(value)
    value == @free_value ? @external_free_value : @external_possible_values[Math.log2(value).to_i - 1]
  end
end
