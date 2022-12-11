#!/usr/bin/env ruby

require 'matrix'

input = File.readlines('./input.txt').map(&:chomp)

class CPU
  attr_reader :cycle, :x, :crt

  def initialize
    @cycle = 0
    @x = 1
    @crt = Matrix.build(6, 40) { nil }
  end

  def noop
    tick
  end

  def add_x(value)
    2.times { tick }
    @x += value.to_i
  end

  def print
    crt.row_vectors.each do |row|
      puts row.to_a.join('')
    end
  end

  private

  def tick
    draw_pixel
    @cycle += 1
  end

  def draw_pixel
    row = cycle / 40
    col = cycle % 40

    crt[row, col] = col.between?(x - 1, x + 1) ? '#' : '.'
  end
end

cpu = CPU.new

input.each do |line|
  if line == 'noop'
    cpu.noop
  elsif (match = line.match(/addx ([0-9\-]+)/))
    cpu.add_x(match[1])
  end
end

cpu.print
