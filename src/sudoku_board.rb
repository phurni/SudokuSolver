class SudokuBoard
  include Enumerable

  attr_reader :dimension, :free_value, :possible_values

  def initialize(dimension: 3, free_value: 0, possible_values: (1..9).to_a)
    @dimension, @row_count, @column_count, @free_value, @possible_values = dimension, dimension**2, dimension**2, free_value, possible_values

    raise ArgumentError if possible_values.size != dimension**2
  end
  
  def each_free_cell
    return to_enum(:each_free_cell) unless block_given?

    each do |column_index, row_index, value|
      yield column_index, row_index if value == @free_value
    end
  end

  def to_external(value)
    value == @free_value ? ' ' : value.to_s
  end
end
