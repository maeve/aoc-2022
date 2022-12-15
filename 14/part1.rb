#!/usr/bin/env ruby
# frozen_string_literal: true

require 'matrix'

class Segment
  # Coordinates are expressed as [row, col]
  attr_reader :start, :finish

  def initialize(start, finish)
    @start = start
    @finish = finish
  end

  def cover?(row, col)
    (rows.min..rows.max).cover?(row) &&
      (columns.min..columns.max).cover?(col)
  end

  def rows
    @rows ||= [start[0], finish[0]]
  end

  def columns
    @columns ||= [start[1], finish[1]]
  end
end

class CaveMap
  attr_reader :segments,
              :source,
              :grid

  ROCK = '#'
  AIR = '.'
  SOURCE = '+'
  SAND = 'o'

  def initialize(lines)
    @segments = parse_segments(lines)
    @source = [0, 500]
    @grid = initialize_grid
  end

  def to_s
    grid.row_vectors.map do |row_vector|
      row_vector.to_a.slice(segment_columns.min..segment_columns.max).join('')
    end.join("\n")
  end

  def produce_sand
    sand = source

    loop do
      down = [sand[0] + 1, sand[1]]
      left = [sand[0] + 1, sand[1] - 1]
      right = [sand[0] + 1, sand[1] + 1]

      if down[0] == grid.row_count
        # We've fallen out the bottom of the grid
        sand = nil
        break
      elsif grid[*down] == AIR
        sand = down
        next
      elsif grid[*left] == AIR
        sand = left
        next
      elsif grid[*right] == AIR
        sand = right
        next
      else
        # Record the spot where we have come to rest
        grid[*sand] = SAND
        break
      end
    end

    sand
  end

  private

  def segment_rows
    segments.map(&:rows).flatten
  end

  def segment_columns
    segments.map(&:columns).flatten
  end

  def initialize_grid
    Matrix.build(segment_rows.max + 1, segment_columns.max + 1) do |row, col|
      if source == [row, col]
        SOURCE
      elsif segments.any? { |s| s.cover?(row, col) }
        ROCK
      else
        AIR
      end
    end
  end

  def parse_segments(lines)
    segments = []

    lines.each do |line|
      coords = line.split(' -> ').map { |pair| pair.split(',').map(&:to_i) }
      coords.each_cons(2) do |start, finish|
        segments << Segment.new(start.reverse, finish.reverse)
      end
    end

    segments
  end
end

input = File.readlines('./input.txt').map(&:chomp)

map = CaveMap.new(input)

puts '== Initial state =='
puts map.to_s

count = 0

loop do
  break unless map.produce_sand

  puts "== Sand #{count += 1} =="
  puts map.to_s
end
