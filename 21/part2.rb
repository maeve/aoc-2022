#!/usr/bin/env ruby
# frozen_string_literal: true

class Monkey
  attr_accessor :name, :number, :left_operand, :right_operand, :operator
  attr_accessor :left, :right

  INVERSE_OPERATORS = {
    '+' => '-',
    '-' => '+',
    '/' => '*',
    '*' => '/'
  }.freeze

  def initialize(input)
    self.name, value = input.split(':')
    value = value.strip

    return if name == 'humn'

    if value =~ /^[0-9]+$/
      self.number = value.to_i
    else
      match = value.match(/^(?<left_operand>[a-z]*) (?<operator>.) (?<right_operand>[a-z]*)$/)
      self.left_operand = match[:left_operand]
      self.right_operand = match[:right_operand]
      self.operator = root? ? '=' : match[:operator]
    end
  end

  def number?
    !number.nil?
  end

  def human?
    name == 'humn'
  end

  def depends_on_human?
    return true if human?
    return false if number?

    left.depends_on_human? || right.depends_on_human?
  end

  def root?
    name == 'root'
  end

  def precalculate
    return if human? || number?

    left_value = right_value = nil

    left_value = left.solve unless left.depends_on_human?
    right_value = right.solve unless right.depends_on_human?

    if left_value && right_value
      self.number = left_value.send(operator, right_value)
    end

    if left_value
      right.precalculate
    else
      left.precalculate
    end
  end

  def solve
    return number if number?

    self.number = left.solve.send(operator, right.solve)
  end

  def inverse_operator
    INVERSE_OPERATORS[operator]
  end

  def to_s
    value = number? ? number : "#{left_operand} #{operator} #{right_operand}"
    "#{name}: #{value}"
  end
end

class MonkeyMap
  attr_accessor :monkeys

  def initialize(input)
    array = input.map { |line| Monkey.new(line) }
    self.monkeys = array.map(&:name).zip(array).to_h

    monkeys.each_value do |monkey|
      monkey.left = monkeys[monkey.left_operand]
      monkey.right = monkeys[monkey.right_operand]
    end
  end

  def root_monkey
    monkeys['root']
  end

  def find_human_value
    root_monkey.precalculate

    fill_in_monkey_numbers(root_monkey)

    monkeys['humn'].number
  end
end

def fill_in_monkey_numbers(monkey)
  if monkey.left.number?
    known = :left
    unknown = :right
  else
    known = :right
    unknown = :left
  end

  known_monkey = monkey.send(known)
  next_monkey = monkey.send(unknown)

  return if next_monkey.nil?

  case monkey.operator
  when '='
    monkey.number = known_monkey.number * 2
    next_monkey.number = known_monkey.number
  when '*'
    next_monkey.number = monkey.number / known_monkey.number
  when '/'
    operator = known == :left ? '/' : '*'
    next_monkey.number = known_monkey.number.send(operator, monkey.number)
  when '+'
    next_monkey.number = monkey.number - known_monkey.number
  when '-'
    operator = known == :left ? '-' : '+'
    next_monkey.number = known_monkey.number.send(operator, monkey.number)
  end

  fill_in_monkey_numbers(next_monkey) unless next_monkey.human?
end

input = File.readlines('./input.txt').map(&:chomp)

map = MonkeyMap.new(input)

puts "Answer: #{map.find_human_value}"
