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

  # We only need to keep track of the top WINDOW_SIZE rows
  WINDOW_SIZE = 100
  WIDTH = 7

  attr_accessor :jet_pattern, :grid, :jet_index, :height, :rock_count, :shape_index, :base_offset, :jet_cycled, :cycle_state

  def initialize(input, rock_count)
    self.jet_pattern = input.chars.map { |c| c == '<' ? -1 : 1 }
    self.jet_index = 0

    self.rock_count = rock_count

    self.grid = Array.new(WINDOW_SIZE + 10) { Array.new(WIDTH) { '.' } }
    self.base_offset = 0
    self.height = 0

    self.shape_index = 0
    self.jet_cycled = false
    self.cycle_state = []
  end

  def drop_all_shapes
    start_state = nil
    end_state = nil

    rock_count.times do |i|
      start_state = detect_cycle(i)
      break if start_state

      drop_shape(create_next_shape)
      slide_window
    end

    end_state = cycle_state.last

    cycle_rocks = end_state[:rock_index] - start_state[:rock_index]
    puts "Cycle rocks: #{cycle_rocks}"
    cycle_height = end_state[:height] - start_state[:height]
    puts "Cycle height: #{cycle_height}"

    rocks_left = rock_count - (end_state[:rock_index])
    puts "Rocks left: #{rocks_left}"
    remaining_cycles = rocks_left / cycle_rocks
    puts "Remaining cycles: #{remaining_cycles}"

    self.height += cycle_height * remaining_cycles
    self.base_offset += cycle_height * remaining_cycles

    (rocks_left % cycle_rocks).times do
      drop_shape(create_next_shape)
      slide_window
    end

    # # Now we know the size of the cycle, the rest should be...easy?
    # cycle_count = rock_count / cycle_moves
    # self.height = cycle_height * cycle_count
    #
    # # The grid will contain the last cycle
    # self.base_offset += height - cycle_height
    #
    # puts "Cycle moves: #{cycle_moves}"
    # puts "Cycle height: #{cycle_height}"
    # puts "Cycle count: #{cycle_count}"
    #
    # puts "New height: #{height}"
    # puts "New base offset: #{base_offset}"
    # puts "Rocks left to process: #{rock_count % cycle_moves}"
    # print_grid
    #
    # (rock_count % cycle_moves).times do
    #   print_grid
    #   drop_shape(create_next_shape)
    #   slide_window
    # end
  end

  def print_grid(shape = nil)
    grid.slice(0, height + 10).reverse.each_with_index do |row, index|
      chars = row.clone

      shape&.coordinates&.each do |x, y|
        chars[x] = '@' if y == (height + 9 - index)
      end

      puts "|#{chars.join('')}|"
    end
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

  def detect_cycle(index)
    return unless jet_cycled && shape_index.zero?

    # This rock starts a new repetition of both the shape types
    # and the jet pattern, so it is a convenient place to check for
    # cycles
    prev = cycle_state.index { |state| state[:jet_index] == jet_index }

    cycle_state << {
      jet_index: jet_index,
      rock_index: index,
      height: height
    }

    self.jet_cycled = false

    cycle_state[prev] if prev
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

  def slide_window
    return unless (height - base_offset) > WINDOW_SIZE

    overhang = height - base_offset - WINDOW_SIZE
    self.base_offset += overhang
    grid.slice!(0, overhang)
    overhang.times { grid << Array.new(WIDTH) { '.' } }
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

    if jet_index > jet_pattern.size
      self.jet_cycled = true
      self.jet_index %= jet_pattern.size
    end

    moves.sum
  end

  def draw_shape(shape)
    shape.coordinates.each do |x, y|
      grid[y - base_offset][x] = '#'
    end
  end

  def blocked?(shape)
    # We hit the floor
    return true if shape.min_y.negative?

    shape.coordinates.any? { |x, y| grid[y - base_offset][x] == '#' }
  end
end

input = File.readlines('./test-input.txt').map(&:chomp)

# count = 1000000000000

count = 2022

shaft = Shaft.new(input.first, count)

shaft.drop_all_shapes

shaft.print_grid

puts "Tower height: #{shaft.height}"
