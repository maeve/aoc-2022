#!/usr/bin/env ruby
# frozen_string_literal: true

class LinkedList
  class Node
    attr_reader :value, :position

    def initialize(value, position)
      @value = value
      @position = position
    end
  end

  attr_reader :original_nodes, :nodes

  def initialize(input, multiplier)
    @original_nodes = []

    input.each_with_index do |str, position|
      value = str.to_i * multiplier
      original_nodes << Node.new(value, position)
    end

    @nodes = original_nodes.clone
  end

  def mix
    original_nodes.each do |node|
      nodes.rotate!(nodes.index(node))
      nodes.shift

      nodes.rotate!(node.value)
      nodes.unshift(node)
    end

    nodes.rotate!(zero_index)
  end

  def to_s
    nodes.map(&:value).join(', ')
  end

  def zero_index
    nodes.index { |node| node.value.zero? }
  end

  def nth_value(offset)
    nodes[offset % nodes.size].value
  end
end

input = File.readlines('./input.txt').map(&:chomp)

file = LinkedList.new(input, 811589153)

puts "Initial arrangement:"
puts file
puts

10.times do |i|
  file.mix
  puts "After #{i + 1} rounds of mixing:"
  puts file
  puts
end

puts "1000th after zero: #{file.nth_value(1000)}"
puts "2000th after zero: #{file.nth_value(2000)}"
puts "3000th after zero: #{file.nth_value(3000)}"

sum = file.nth_value(1000) + file.nth_value(2000) + file.nth_value(3000)

puts "Sum: #{sum}"
