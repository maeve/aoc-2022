#!/usr/bin/env ruby
# frozen_string_literal: true

class Shape
  # Coordinates start with bottom left and end with top right
  attr_accessor :coordinates

  def left(count = 1)
    coordinates.each do |coord|
      coord[0] -= count
    end
  end

  def right(count = 1)
    coordinates.each do |coord|
      coord[0] += count
    end
  end

  def down(count = 1)
    coordinates.each do |coord|
      coord[1] -= count
    end
  end

  def up(count = 1)
    coordinates.each do |coord|
      coord[1] += count
    end
  end

  def height
    max_y - min_y
  end

  def max_y
    coordinates.map(&:last).max
  end

  def min_y
    coordinates.map(&:last).min
  end

  def min_x
    coordinates.map(&:first).min
  end

  def max_x
    coordinates.map(&:first).max
  end
end

class Minus < Shape
  def initialize(x, y)
    self.coordinates = [
      [x, y],
      [x + 1, y],
      [x + 2, y],
      [x + 3, y]
    ]
  end
end

class Plus < Shape
  def initialize(x, y)
    self.coordinates = [
      [x, y + 1],
      [x + 1, y],
      [x + 1, y + 1],
      [x + 2, y + 1],
      [x + 1, y + 2]
    ]
  end
end

class Angle < Shape
  def initialize(x, y)
    self.coordinates = [
      [x, y],
      [x + 1, y],
      [x + 2, y],
      [x + 2, y + 1],
      [x + 2, y + 2]
    ]
  end
end

class Line < Shape
  def initialize(x, y)
    self.coordinates = [
      [x, y],
      [x, y + 1],
      [x, y + 2],
      [x, y + 3]
    ]
  end
end

class Square < Shape
  def initialize(x, y)
    self.coordinates = [
      [x, y],
      [x + 1, y],
      [x, y + 1],
      [x + 1, y + 1]
    ]
  end
end

class Shaft
  SHAPES = [Minus, Plus, Angle, Line, Square].freeze

  WIDTH = 7

  attr_accessor :jet_pattern, :grid, :jet_index, :height, :rock_count, :shape_index

  def initialize(input, rock_count)
    self.jet_pattern = input.chars.map { |c| c == '<' ? -1 : 1 }
    self.rock_count = rock_count
    self.grid = Array.new(rock_count * 5) { Array.new(WIDTH) { '.' } }
    self.jet_index = 0
    self.height = 0
    self.shape_index = 0
  end

  def drop_all_shapes
    rock_count.times do
      drop_shape(create_next_shape)

      # puts "After dropping shape height=#{height}"
      # print_grid
    end
  end

  def print_grid(shape = nil)
    grid.slice(0, height + 10).reverse.each_with_index do |row, index|
      chars = row.clone

      shape&.coordinates&.each do |x, y|
        chars[x] = '@' if y == (height + 9 - index)
      end

      puts "|#{chars.join('')}|"
    end
    puts "+#{'-' * WIDTH}+"
    puts
  end

  private

  def create_next_shape
    x = 2
    y = height + 3

    shape = SHAPES[shape_index].new(x, y)

    self.shape_index += 1
    self.shape_index %= SHAPES.size

    shape
  end

  def drop_shape(shape)
    # We know we can safely move at least 3 times without bumping into
    # another piece, because of where the initial drop point is
    move_shape(shape, 3)

    # Move 1 at a time until we hit something
    move_shape(shape, 1) until blocked?(shape)

    # Back off the last move that blocked us
    shape.up

    draw_shape(shape)
    self.height = [height, shape.max_y + 1].max
  end

  def move_shape(shape, count)
    lateral_offset = adjust_gas_jets(count)

    if lateral_offset.negative?
      adjusted_x = shape.min_x + lateral_offset
      lateral_offset = shape.min_x if adjusted_x.negative?

      shape.left(lateral_offset.abs)
      shape.right while blocked?(shape)
    else
      adjusted_x = shape.max_x + lateral_offset
      lateral_offset -= adjusted_x - Shaft::WIDTH + 1 if adjusted_x >= Shaft::WIDTH
      shape.right(lateral_offset)
      shape.left while blocked?(shape)
    end

    shape.down(count)
  end

  def adjust_gas_jets(count)
    moves = jet_pattern.slice(jet_index, count)
    moves += jet_pattern.slice(0, count - moves.size) if moves.size < count

    self.jet_index += count
    self.jet_index %= jet_pattern.size

    moves.sum
  end

  def draw_shape(shape)
    shape.coordinates.each do |x, y|
      grid[y][x] = '#'
    end
  end

  def blocked?(shape)
    # We hit the floor
    return true if shape.min_y.negative?

    shape.coordinates.any? { |x, y| grid[y][x] == '#' }
  end
end

input = File.readlines('./test-input.txt').map(&:chomp)

# count = 1000000000000

count = 2022

shaft = Shaft.new(input.first, count)

shaft.drop_all_shapes

# shaft.print_grid

puts "Tower height: #{shaft.height}"
