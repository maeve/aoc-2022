#!/usr/bin/env ruby

input = File.readlines('./input.txt').map(&:chomp)

class CPU
  attr_accessor :cycle, :x, :sum_signal

  def initialize
    @cycle = 0
    @x = 1
    @sum_signal = 0
  end

  def tick
    self.cycle += 1

    if cycle == 20 ||
        (cycle - 20) % 40 == 0
      puts "Cycle: #{cycle}, Signal strength: #{signal_strength}"
      self.sum_signal += signal_strength
    end
  end
  
  def to_s
    "Cycle: #{cycle}, X: #{x}"
  end

  def signal_strength
    cycle * x
  end
end

cpu = CPU.new

input.each do |line|
  if line == 'noop'
    cpu.tick
  elsif (match = line.match(/addx ([0-9\-]+)/))
    cpu.tick
    cpu.tick
    cpu.x += match[1].to_i
  end
end

puts "Sum signal: #{cpu.sum_signal}"
