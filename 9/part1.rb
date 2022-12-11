#!/usr/bin/env ruby

require 'matrix'

input = File.readlines('./input.txt').map(&:chomp)

class Grid
  attr_reader :grid, :head, :tail

  def initialize(size = 300)
    @grid = Matrix.build(size, size) { |row, col| 0 }
    @head = [0, 0]
    @tail = [0, 0]
    @grid[*tail] = 1
  end

  def print(label)
    puts "== #{label} ==\n"

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
        head[1] += 1
      when "L"
        head[1] -= 1
      when "U"
        head[0] += 1
      when "D"
        head[0] -= 1
      end

      move_tail
    end
  end

  def positions_visited
    grid.sum
  end

  private

  def move_tail
    # Don't move tail if it is already touching
    row_diff = head[0] - tail[0]
    col_diff = head[1] - tail[1]

    return if row_diff.between?(-1, 1) && col_diff.between?(-1, 1)

    if row_diff.positive?
      tail[0] += 1
    elsif row_diff.negative?
      tail[0] -= 1
    end

    if col_diff.positive?
      tail[1] += 1
    elsif col_diff.negative?
      tail[1] -= 1
    end

    grid[*tail] = 1
  end

  def position_char(row, col)
    if head == [row, col]
      'H'
    elsif tail == [row, col]
      'T'
    elsif [0, 0] == [row, col]
      's'
    elsif grid[row, col] == 1
      '#'
    else
      '.'
    end
  end
end

grid = Grid.new

grid.print("Initial state")

input.each do |line|
  direction, steps = line.split(" ")
  grid.move_head(direction, steps)
  # grid.print(line)
end

grid.print("Final")

puts "Positions visited: #{grid.positions_visited}"
