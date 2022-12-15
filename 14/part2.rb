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
              :floor,
              :source,
              :grid,
              :sand

  ROCK = '#'
  AIR = '.'
  SOURCE = '+'
  SAND = 'o'

  def initialize(lines)
    @segments = parse_segments(lines)
    @floor = segment_rows.max + 2
    @source = [0, 500]
    @grid = initialize_grid
    @sand = []
  end

  def to_s
    columns = segment_columns
    columns += sand.map(&:last) unless sand.empty?

    grid.row_vectors.slice(0..floor).map do |row_vector|
      row_vector.to_a.slice(columns.min..columns.max).join('')
    end.join("\n")
  end

  def produce_sand
    sand_grain = source

    loop do
      down = [sand_grain[0] + 1, sand_grain[1]]
      left = [sand_grain[0] + 1, sand_grain[1] - 1]
      right = [sand_grain[0] + 1, sand_grain[1] + 1]

      break if down[0] == floor

      if grid[*down] == AIR
        sand_grain = down
        next
      elsif grid[*left] == AIR
        sand_grain = left
        next
      elsif grid[*right] == AIR
        sand_grain = right
        next
      else
        # We've come to rest
        break
      end
    end

    grid[*sand_grain] = SAND
    sand << sand_grain
    sand_grain
  end

  private

  def segment_rows
    segments.map(&:rows).flatten
  end

  def segment_columns
    segments.map(&:columns).flatten
  end

  def initialize_grid
    Matrix.build(floor + 1, source[1] + floor + 1) do |row, col|
      if source == [row, col]
        SOURCE
      elsif row == floor || segments.any? { |s| s.cover?(row, col) }
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
  puts "== Sand #{count += 1} =="
  sand = map.produce_sand
  puts map.to_s if (count % 10).zero?
  break if sand == map.source
end

puts "Sand count: #{count}"
