#!/usr/bin/env ruby
# frozen_string_literal: true


class Droplet
  attr_accessor :grid, :coordinates

  def initialize(input)
    self.coordinates = input.map { |line| line.split(',').map(&:to_i) }

    max_x = coordinates.map { |x, _y, _z| x }.max
    max_y = coordinates.map { |_x, y, _z| y }.max
    max_z = coordinates.map { |_x, _y, z| z }.max

    # Intentionally making the grid a bit too large so that we don't have to worry
    # about going out of bounds when searching for adjacencies
    self.grid = Array.new(max_x + 2) { Array.new(max_y + 2) { Array.new(max_z + 2) } }
    coordinates.each { |x, y, z| grid[x][y][z] = '#' }
  end

  def surface_area
    area = 0

    coordinates.each do |x, y, z|
      area += 1 unless grid[x + 1][y][z]
      area += 1 unless grid[x - 1][y][z]
      area += 1 unless grid[x][y + 1][z]
      area += 1 unless grid[x][y - 1][z]
      area += 1 unless grid[x][y][z + 1]
      area += 1 unless grid[x][y][z - 1]
    end

    area
  end
end

input = File.readlines('./input.txt').map(&:chomp)

# input = [
# "1,1,1",
# "2,1,1"
# ]

droplet = Droplet.new(input)
puts "Droplet surface area: #{droplet.surface_area}"
