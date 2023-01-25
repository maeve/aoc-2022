#!/usr/bin/env ruby
# frozen_string_literal: true

class Node
  attr_accessor :value, :next, :prev

  def initialize(value)
    self.value = value.to_i
  end
end

class LinkedList
  attr_accessor :nodes, :zero

  def initialize(input)
    self.nodes = input.map { |value| Node.new(value) }

    nodes.each_with_index do |node, index|
      node.next = index + 1 < nodes.size ? nodes[index + 1] : nodes.first
      node.prev = index.zero? ? nodes.last : nodes[index - 1]
    end
  end

  def mix
    nodes.each do |node|
      next if node.value.zero?

      steps = node.value.abs

      steps.times do
        if node.value.positive?
          new_next = node.next.next
          new_prev = node.next
        elsif node.value.negative?
          new_next = node.prev
          new_prev = node.prev.prev
        end

        node.prev.next = node.next
        node.next.prev = node.prev

        node.next = new_next
        new_next.prev = node
        node.prev = new_prev
        new_prev.next = node
      end
    end
  end

  def to_s
    strings = []

    head = next_node = nodes.first

    loop do
      strings << next_node.value.to_s
      next_node = next_node.next

      break if next_node == head
    end

    strings.join(', ')
  end

  def zero_node
    @zero_node ||= nodes.detect { |node| node.value.zero? }
  end

  def nth_value_after_zero(nth)
    current = zero_node

    nth.times do
      current = current.next
    end

    current.value
  end
end

input = File.readlines('./input.txt').map(&:chomp)

file = LinkedList.new(input)

file.mix

puts "Result after mixing: #{file}"

puts "1000th after zero: #{file.nth_value_after_zero(1000)}"
puts "2000th after zero: #{file.nth_value_after_zero(2000)}"
puts "3000th after zero: #{file.nth_value_after_zero(3000)}"

sum = file.nth_value_after_zero(1000) + file.nth_value_after_zero(2000) + file.nth_value_after_zero(3000)

puts "Sum: #{sum}"
