#!/usr/bin/env ruby

require 'matrix'

input = File.readlines('./input.txt').map(&:chomp)

class Grid
  attr_reader :grid, :rope

  def initialize(size = 300)
    @grid = Matrix.build(size, size) { |row, col| 0 }
    @rope = Array.new(10) { [0, 0] }
    record_tail
  end

  def print(label = nil)
    puts "== #{label} ==\n" if label

    row = grid.row_count - 1
    until row.negative?
      row_string = ''
      grid.row(row).to_a.each_index do |col|
        row_string += position_char(row, col)
      end

      puts row_string

      row -= 1
    end

    puts
  end

  def move_head(direction, steps)
    steps.to_i.times do
      case direction
      when "R"
        rope.first[1] += 1
      when "L"
        rope.first[1] -= 1
      when "U"
        rope.first[0] += 1
      when "D"
        rope.first[0] -= 1
      end

      move_rope(1)
    end
  end

  def positions_visited
    grid.sum
  end

  private

  def record_tail
    grid[*rope.last] = 1
  end

  def move_rope(index)
    # Don't move tail if it is already touching
    curr = rope[index]
    prev = rope[index - 1]

    row_diff = prev[0] - curr[0]
    col_diff = prev[1] - curr[1]

    return if row_diff.between?(-1, 1) && col_diff.between?(-1, 1)

    if row_diff.positive?
      curr[0] += 1
    elsif row_diff.negative?
      curr[0] -= 1
    end

    if col_diff.positive?
      curr[1] += 1
    elsif col_diff.negative?
      curr[1] -= 1
    end

    if index == rope.length - 1
      record_tail
    else
      move_rope(index + 1)
    end
  end

  def position_char(row, col)
    if rope.first == [row, col]
      'H'
    elsif (index = rope.index([row, col]))
      index.to_s
    elsif [0, 0] == [row, col]
      's'
    # elsif grid[row, col] == 1
    #   '#'
    else
      '.'
    end
  end
end

grid = Grid.new

input.each do |line|
  direction, steps = line.split(' ')
  grid.move_head(direction, steps)
end

puts "Positions visited: #{grid.positions_visited}"
