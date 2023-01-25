#!/usr/bin/env ruby
# frozen_string_literal: true

class Monkey
  attr_accessor :name, :number, :left_operand, :right_operand, :operator

  def initialize(input)
    self.name, value = input.split(':')
    value = value.strip

    if value =~ /^[0-9]+$/
      self.number = value.to_i
    else
      match = value.match(/^(?<left_operand>[a-z]*) (?<operator>.) (?<right_operand>[a-z]*)$/)
      self.left_operand = match[:left_operand]
      self.operator = match[:operator]
      self.right_operand = match[:right_operand]
    end
  end
end

class MonkeyMap
  attr_accessor :monkeys

  def initialize(input)
    self.monkeys = {}

    input.each do |line|
      monkey = Monkey.new(line)
      monkeys[monkey.name] = monkey
    end
  end

  def yell(name)
    monkey = monkeys[name]

    return monkey.number unless monkey.number.nil?

    left = yell(monkey.left_operand)
    right = yell(monkey.right_operand)

    left.send(monkey.operator, right)
  end
end

input = File.readlines('./input.txt').map(&:chomp)

map = MonkeyMap.new(input)

puts "Answer: #{map.yell('root')}"
