#!/usr/bin/env ruby
# frozen_string_literal: true


class Droplet
  attr_accessor :grid, :coordinates

  def initialize(input)
    self.coordinates = input.map { |line| line.split(',').map(&:to_i) }

    # Intentionally making the grid a bit too large so that we don't have to worry
    # about going out of bounds when searching for adjacencies
    self.grid = Array.new(max_x + 3) { Array.new(max_y + 3) { Array.new(max_z + 3) } }
    coordinates.each { |x, y, z| grid[x + 1][y + 1][z + 1] = '#' }
  end

  def surface_area
    area = 0

    spread_steam(0, 0, 0)

    grid.each_with_index do |plane, x|
      plane.each_with_index do |row, y|
        row.each_with_index do |element, z|
          next unless element == '@'

          area += 1 if x.positive? && grid[x - 1][y][z] == '#'
          area += 1 if x <= max_x && grid[x + 1][y][z] == '#'
          area += 1 if y.positive? && grid[x][y - 1][z] == '#'
          area += 1 if y <= max_y && grid[x][y + 1][z] == '#'
          area += 1 if z.positive? && grid[x][y][z - 1] == '#'
          area += 1 if z <= max_z && grid[x][y][z + 1] == '#'
        end
      end
    end

    area
  end

  def print
    grid.each_with_index do |plane, x|
      puts "Plane at x=#{x}"
      puts ' z=  000000000011111111112'
      puts '     012345678901234567890'
      plane.each_with_index do |arr, y|
        line = arr.map { |e| e || '.' }.join('')
        puts "y=#{format('%02d',y)} #{line}"
      end

      puts
    end
  end

  private

  def max_x
    @max_x ||= coordinates.map { |x, _y,_z| x }.max
  end

  def max_y
    @max_y ||= coordinates.map { |_x, y, _z| y }.max
  end

  def max_z
    @max_z ||= coordinates.map { |_x, _y, z| z }.max
  end

  def min_x
    @min_x ||= coordinates.map { |x, _y,_z| x }.min
  end

  def min_y
    @min_y ||= coordinates.map { |_x, y, _z| y }.min
  end

  def min_z
    @min_z ||= coordinates.map { |_x, _y, z| z }.min
  end

  def spread_steam(x, y, z)
    return unless x.between?(0, max_x + 2) &&
                  y.between?(0, max_y + 2) &&
                  z.between?(0, max_z + 2) &&
                  grid[x][y][z].nil?

    grid[x][y][z] = '@'

    spread_steam(x + 1, y, z)
    spread_steam(x - 1, y, z)
    spread_steam(x, y + 1, z)
    spread_steam(x, y - 1, z)
    spread_steam(x, y, z + 1)
    spread_steam(x, y, z - 1)
  end
end

input = File.readlines('./input.txt').map(&:chomp)

droplet = Droplet.new(input)
puts "=== Before steam ==="
puts
droplet.print
puts

puts "Droplet surface area: #{droplet.surface_area}"
puts

puts "=== After steam ==="
puts
droplet.print
