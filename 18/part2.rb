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
      exposed_edges = []
      exposed_edges << [x + 1, y, z] unless grid[x + 1][y][z]
      exposed_edges << [x - 1, y, z] unless grid[x - 1][y][z]
      exposed_edges << [x, y + 1, z] unless grid[x][y + 1][z]
      exposed_edges << [x, y - 1, z] unless grid[x][y - 1][z]
      exposed_edges << [x, y, z + 1] unless grid[x][y][z + 1]
      exposed_edges << [x, y, z - 1] unless grid[x][y][z - 1]

      # Now we need to make sure each exposed edge is reachable by steam
      exposed_edges.each do |x, y, z|
        next unless grid[x][y][0..(z - 1)].all?(&:nil?) ||
                    grid[x][y][(z + 1)..].all?(&:nil?) ||
                    grid[x][0..(y - 1)].all? { |line| line[z].nil? } ||
                    grid[x][(y + 1)..].all? { |line| line[z].nil? } ||
                    grid[0..(x - 1)].all? { |plane| plane[y][z].nil? } ||
                    grid[(x + 1)..].all? { |plane| plane[y][z].nil? }

        area += 1
      end
    end

    area
  end

  def print
    grid.each_with_index do |plane, x|
      puts "Plane at x=#{x}"
      puts " z= 01234567"
      plane.each_with_index do |arr, y|
        line = arr.map { |e| e || '.' }.join('')
        puts "y=#{y} #{line}"
      end

      puts
    end
  end
end

input = File.readlines('./input.txt').map(&:chomp)

droplet = Droplet.new(input)
droplet.print
puts "Droplet surface area: #{droplet.surface_area}"
