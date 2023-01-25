#!/usr/bin/env ruby
# frozen_string_literal: true

class LinkedList
  attr_accessor :original_nodes, :mixed_nodes

  def initialize(input, multiplier)
    self.original_nodes = input.map { |value| value.to_i * multiplier }
    self.mixed_nodes = original_nodes.clone
  end

  def mix
    original_nodes.each do |value|
      index = mixed_nodes.index(value)
      mixed_nodes.rotate!(index)

      current = mixed_nodes.shift

      mixed_nodes.rotate!(current)
      mixed_nodes.unshift(current)
    end
  end

  def to_s
    mixed_nodes.rotate!(mixed_nodes.index(0))
    mixed_nodes.join(', ')
  end

  def nth_value_after_zero(nth)
    mixed_nodes.rotate!(mixed_nodes.index(0))

    mixed_nodes.rotate!(nth)

    mixed_nodes.first
  end
end

input = File.readlines('./test-input.txt').map(&:chomp)

file = LinkedList.new(input, 811589153)

puts "Initial arrangement:"
puts file.original_nodes.join(", ")
puts

10.times do |i|
  file.mix
  puts "After #{i + 1} rounds of mixing:"
  puts file
  puts
end

puts "1000th after zero: #{file.nth_value_after_zero(1000)}"
puts "2000th after zero: #{file.nth_value_after_zero(2000)}"
puts "3000th after zero: #{file.nth_value_after_zero(3000)}"

sum = file.nth_value_after_zero(1000) + file.nth_value_after_zero(2000) + file.nth_value_after_zero(3000)

puts "Sum: #{sum}"
