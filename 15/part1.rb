#!/usr/bin/env ruby
# frozen_string_literal: true

require 'matrix'

class Sensor
  # Coordinates are stored as [row, col] (or [y, x])
  attr_reader :coordinate, :beacon

  def initialize(col, row, beacon_col, beacon_row)
    @coordinate = [row.to_i, col.to_i]
    @beacon = [beacon_row.to_i, beacon_col.to_i]
  end

  def distance_from(other_row, other_col)
    (row - other_row).abs + 
      (col - other_col).abs
  end

  def beacon_distance
    distance_from(*beacon)
  end

  def row
    coordinate[0]
  end

  def col
    coordinate[1]
  end

  def at?(row, col)
    coordinate == [row, col]
  end

  def beacon?(row, col)
    beacon == [row, col]
  end

  def no_beacon?(row, col)
    !beacon?(row, col) && distance_from(row, col) <= beacon_distance
  end
end

class CaveMap
  attr_reader :sensors

  def initialize(lines)
    @sensors = parse_sensors(lines)
  end

  def no_beacon_count(row)
    count = 0

    (max_col - min_col + 1).times do |i|
      col = i + min_col
      count += 1 if sensors.any? { |s| s.no_beacon?(row, col) }
    end

    count
  end

  private

  def min_row
    @min_row ||= sensors.map { |s| s.row - s.beacon_distance }.min
  end

  def max_row
    @max_row ||= sensors.map { |s| s.row + s.beacon_distance }.max
  end

  def min_col
    @min_col ||= sensors.map { |s| s.col - s.beacon_distance }.min
  end

  def max_col
    @max_col ||= sensors.map { |s| s.col + s.beacon_distance }.max
  end

  private

  def parse_sensors(lines)
    lines.map do |line|
      match = line.match(/Sensor at x=([0-9-]+), y=([0-9-]+): closest beacon is at x=([0-9-]+), y=([0-9-]+)/)
      Sensor.new(*match.to_a.slice(1..4))
    end
  end
end

input = File.readlines('./input.txt').map(&:chomp)

map = CaveMap.new(input)

puts '== Initial state =='

row = 2_000_000
puts "No beacon count on row #{row}: #{map.no_beacon_count(row)}"
