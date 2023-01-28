#!/usr/bin/env ruby
# frozen_string_literal: true

require 'matrix'

class BoardMap
  attr_accessor :path, :board, :directions, :current_position

  OPEN = '.'
  WALL = '#'
  BLANK = ' '

  FACING_SCORE = {
    right: 0,
    down: 1,
    left: 2,
    up: 3
  }.freeze

  def initialize(input)
    self.path = input.pop.gsub(/(?<turn>[LR])/, ' \k<turn> ').strip.split(' ')

    # Blank line
    input.pop

    self.board = Matrix.build(input.size, input.map(&:size).max) do |row_index, col_index|
      if col_index >= input[row_index].size
        BLANK
      else
        input[row_index][col_index]
      end
    end

    self.directions = %i[right down left up]
    self.current_position = [0, first_index(board.row(0).to_a)]
  end

  def follow_path
    puts "Initial position: #{current_position.inspect}"
    puts "Initial facing: #{facing}"
    puts

    path.each do |step|
      if step =~ /^[0-9]+$/
        puts "Move #{step} in direction #{facing}"
        move(step.to_i)
      else
        puts "Turn #{step} from direction #{facing}"
        turn(step)
      end

      puts "Current position; #{current_position.inspect}"
      puts "Currently facing: #{facing}"
      puts
    end

    1000 * (current_position[0] + 1) + 4 * (current_position[1] + 1) + FACING_SCORE[facing]
  end

  private

  def facing
    directions.first
  end

  def row
    board.row(current_position.first).to_a
  end

  def column
    board.column(current_position.last).to_a
  end

  def first_index(array)
    array.index { |space| space != BLANK }
  end

  def last_index(array)
    array.rindex { |space| space != BLANK }
  end

  def move(distance)
    steps_left = distance

    until steps_left.zero?
      case facing
      when :right
        new_col = current_position.last + 1
        new_col = first_index(row) if new_col >= row.size || row[new_col] == BLANK

        return if row[new_col] == WALL

        current_position[1] = new_col
      when :left
        new_col = current_position.last - 1
        new_col = last_index(row) if new_col.negative? || row[new_col] == BLANK

        return if row[new_col] == WALL

        current_position[1] = new_col
      when :up
        new_row = current_position.first - 1
        new_row = last_index(column) if new_row.negative? || column[new_row] == BLANK

        return if column[new_row] == WALL

        current_position[0] = new_row
      when :down
        new_row = current_position.first + 1
        new_row = first_index(column) if new_row >= column.size || column[new_row] == BLANK

        return if column[new_row] == WALL

        current_position[0] = new_row
      end

      steps_left -= 1
    end
  end

  def turn(direction)
    case direction
    when 'R' then directions.rotate!(1)
    when 'L' then directions.rotate!(-1)
    end
  end
end

input = File.readlines('./input.txt').map(&:chomp)

map = BoardMap.new(input)

puts "Answer: #{map.follow_path}"
