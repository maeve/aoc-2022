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

    puts "Monkeys after calculation"
    monkeys.each_value do |monkey|
      puts monkey
    end
    puts

    fill_in_monkey_numbers(root_monkey)

    puts "Monkeys after filling in"
    monkeys.each_value do |monkey|
      puts monkey
    end
    puts

    monkeys['humn'].number
  end
end

def fill_in_monkey_numbers(monkey)
  if monkey.left.number?
    known_monkey = monkey.left
    next_monkey = monkey.right
  else
    known_monkey = monkey.right
    next_monkey = monkey.left
  end

  puts "Current monkey: #{monkey}"
  puts "Known monkey: #{known_monkey}"
  puts "Next monkey: #{next_monkey}"

  return if next_monkey.nil?

  if monkey.operator == '='
    monkey.number = known_monkey.number * 2
    next_monkey.number = known_monkey.number
  else
    next_monkey.number = monkey.number.send(monkey.inverse_operator, known_monkey.number)
  end

  puts "Current monkey after: #{monkey.number}"
  puts "Next monkey after: #{next_monkey.number}"

  fill_in_monkey_numbers(next_monkey) unless next_monkey.human?
end

input = File.readlines('./test-input.txt').map(&:chomp)

map = MonkeyMap.new(input)

puts "Answer: #{map.find_human_value}"
