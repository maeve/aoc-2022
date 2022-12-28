#!/usr/bin/env ruby
# frozen_string_literal: true

require 'matrix'

class Shape
  attr_accessor :coordinates

  def left
    return if coordinates.detect { |x, _| x == 1 }

    coordinates.each do |coord|
      coord[0] -= 1
    end
  end

  def right
    return if coordinates.detect { |x, _| x == 7 }

    coordinates.each do |coord|
      coord[0] += 1
    end
  end

  def down
    coordinates.each do |coord|
      coord[1] -= 1
    end
  end

  def up
    coordinates.each do |coord|
      coord[1] += 1
    end
  end

  def max_y
    coordinates.map(&:last).max
  end

  def min_y
    coordinates.map(&:last).min
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
      [x + 1, y + 2],
      [x + 2, y + 1]
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
      [x, y + 1],
      [x + 1, y],
      [x + 1, y + 1]
    ]
  end
end

class Shaft
  SHAPES = [Minus, Plus, Angle, Line, Square].freeze

  REVERSE_MOVES = {
    left: :right,
    right: :left,
    up: :down,
    down: :up
  }.freeze

  attr_accessor :jet_pattern, :dropped_shapes, :jet_index

  def initialize(input)
    self.jet_pattern = input.chars.map { |c| c == '<' ? :left : :right }
    self.dropped_shapes = []
    self.jet_index = 0
  end

  def drop_shape
    shape = create_next_shape

    # puts 'A new rock begins falling:'
    # print_grid(shape)

    loop do
      move_shape(shape, jet_pattern[jet_index])
      advance_jet_index
      break unless move_shape(shape, :down)
    end

    dropped_shapes << shape
  end

  def height(shape = nil)
    shapes = dropped_shapes + [shape]
    shapes.compact.map(&:max_y).max.to_i
  end

  def width
    7
  end

  def print_grid(current_shape = nil)
    grid = Matrix.build(height(current_shape) + 1, width + 2) do |row, col|
      if row.zero?
        if col.zero? || col == width + 1
          '+'
        else
          '-'
        end
      elsif col.zero? || col == width + 1
        '|'
      else
        '.'
      end
    end

    dropped_shapes.each do |shape|
      shape.coordinates.each do |x, y|
        grid[y, x] = '#'
      end
    end

    current_shape&.coordinates&.each do |x, y|
      grid[y, x] = '@'
    end

    grid.row_vectors.reverse.each do |row_vector|
      puts row_vector.to_a.join('')
    end

    puts
  end

  private

  def create_next_shape
    x = 3
    y = dropped_shapes.map(&:max_y).max.to_i + 4

    next_shape_class.new(x, y)
  end

  def next_shape_class
    shape_index = dropped_shapes.last ? SHAPES.index(dropped_shapes.last.class) + 1 : 0
    shape_index %= SHAPES.size
    SHAPES[shape_index]
  end

  def advance_jet_index
    self.jet_index += 1
    self.jet_index %= jet_pattern.size
  end

  def blocked?(shape)
    # We hit the floor
    return true if shape.min_y.zero?

    # Check up to the last 10 shapes to see if we have a collision
    count = dropped_shapes.size > 20 ? 20 : dropped_shapes.size
    dropped_shapes[-count..].any? { |s| !(shape.coordinates & s.coordinates).empty? }
  end
  
  def move_shape(shape, move)
    shape.send(move)

    blocked = blocked?(shape)
    shape.send(REVERSE_MOVES[move]) if blocked

    !blocked
  end
end

input = File.readlines('./input.txt').map(&:chomp)

shaft = Shaft.new(input.first)

2022.times do |i|
  # puts "=== Dropping shape #{i + 1} ==="
  shaft.drop_shape
  # puts
end

puts "Tower height: #{shaft.height}"
