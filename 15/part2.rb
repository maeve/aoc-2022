#!/usr/bin/env ruby
# frozen_string_literal: true

require 'matrix'

class Sensor
  # Coordinates are stored as [row, col] (or [y, x])
  attr_reader :coordinate, :beacon, :min, :max

  def initialize(col, row, beacon_col, beacon_row, min, max)
    @coordinate = [row.to_i, col.to_i]
    @beacon = [beacon_row.to_i, beacon_col.to_i]
    @min = min
    @max = max
  end

  def distance_from(other_coordinate)
    coordinate.zip(other_coordinate).map { |a, b| (a - b).abs }.inject(:+)
  end

  def beacon_distance
    distance_from(beacon)
  end

  def range_at(row)
    height = (row - coordinate[0]).abs
    remaining_distance = beacon_distance - height
    range = nil

    if remaining_distance.positive?
      x_min = [coordinate[1] - remaining_distance, min].max
      x_min = max if x_min > max
      x_max = [coordinate[1] + remaining_distance, max].min
      range = x_min..x_max
    end

    range
  end
end

class CaveMap
  attr_reader :sensors, :min, :max

  def initialize(lines, min, max)
    @min = min
    @max = max
    @sensors = parse_sensors(lines)
  end

  def search
    (min..max).each do |row|
      covered = [0, 0]

      covered_ranges_at(row).each do |range|
        if (col = covered[1] + 1) < range.min
          puts "Found the gap at y=#{row}, x=#{col}"
          return col * 4_000_000 + row
        end

        expand_coverage(covered, range)

        break if covered == [min, max]
      end
    end
  end

  private

  def covered_ranges_at(row)
    sensors.map { |s| s.range_at(row) }.compact.sort do |a, b|
      if a.min != b.min
        a.min <=> b.min
      else
        a.max <=> b.max
      end
    end
  end

  def expand_coverage(covered, range)
    return unless range.include?(covered[1]) && covered[1] < range.max

    covered[1] = range.max
  end

  def parse_sensors(lines)
    lines.map do |line|
      match = line.match(/Sensor at x=([0-9-]+), y=([0-9-]+): closest beacon is at x=([0-9-]+), y=([0-9-]+)/)
      Sensor.new(*match.to_a.slice(1..4), min, max)
    end
  end
end

input = File.readlines('./input.txt').map(&:chomp)

map = CaveMap.new(input, 0, 4_000_000)

puts "Distress beacon frequency: #{map.search}"
