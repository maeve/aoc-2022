#!/usr/bin/env ruby

input = File.readlines('./test-input.txt').map(&:chomp)

class Item
  attr_accessor :divisor,
                :quotient,
                :remainder,
                :id

  def self.id_generator
    @id_generator ||= 0
    @id_generator += 1
  end

  def initialize(value)
    self.id = Item.id_generator
    self.divisor = 2
    self.quotient = value / divisor
    self.remainder = value % divisor
  end

  def perform(operation, operand)
    value = operand == :old ? clone : operand
    send(operation, value)
  end

  def test(value)
    (to_i % value).zero?
  end

  def to_s
    "(id=#{id}): #{quotient} * #{divisor} + #{remainder} = #{to_i}"
  end

  def to_i
    quotient * divisor + remainder
  end

  protected

  def *(other)
    if other.is_a?(Item)
      self.divisor += other.divisor
      self.remainder += other.remainder
    else
      self.divisor *= other
      self.remainder *= other
    end

    rebalance
  end

  def +(other)
    if other.is_a?(Item)
      self.divisor += other.divisor
      self.remainder += other.remainder
    else
      self.quotient += other / divisor
      self.remainder += other % divisor
    end

    rebalance
  end

  def -(other)
    if other.is_a?(Item)
      self.divisor -= other.divisor
      self.remainder -= other.remainder
    else
      self.quotient -= other / divisor
      self.remainder -= other % divisor
    end

    rebalance
  end

  def rebalance
    self.quotient += remainder / divisor
    self.remainder %= divisor
  end
end

class Monkey
  attr_reader :name,
              :items,
              :operation,
              :operand,
              :test,
              :outcomes,
              :inspections

  def initialize(input)
    lines = input.clone

    self.name = lines.shift
    self.items = lines.shift
    self.operation = lines.shift
    self.test = lines.shift

    @outcomes = {}
    add_outcome(lines.shift) until lines.empty?

    @inspections = 0
  end

  def inspect_item
    item = items.shift

    item.perform(operation, operand)

    target = outcomes[item.test(test)]

    @inspections += 1

    [target, item]
  end

  def to_s
    "Monkey #{name}: #{items.join(', ') }"
  end

  private

  def name=(line)
    @name = line.strip.match(/Monkey ([0-9]+):/)[1]
  end

  def items=(line)
    @items = line.strip.match(/Starting items: ([0-9, ]+)/)[1].split(',').map do |item|
      Item.new(item.strip.to_i)
    end
  end

  def operation=(line)
    match = line.strip.match(/Operation: new = old (.) ([[0-9a-z]]+)/)
    @operation = match[1].to_sym
    @operand = match[2] == 'old' ? :old : match[2].to_i
  end

  def test=(line)
    @test = line.strip.match(/Test: divisible by ([0-9]+)/)[1].to_i
  end

  def add_outcome(line)
    match = line.strip.match(/If ([a-z]+): throw to monkey ([0-9]+)/)
    return unless match

    outcome = (match[1] == 'true')
    @outcomes[outcome] = match[2].to_i
  end
end

monkeys = []

input.each_slice(7) do |lines|
  monkeys << Monkey.new(lines)
end

def print_monkeys(monkeys)
  monkeys.each do |monkey|
    puts "Monkey #{monkey.name} items:"
    puts monkey.items
  end

  puts ''
end

puts "== Initial state =="

print_monkeys(monkeys)

1000.times do |i|
  monkeys.each do |monkey|
    until monkey.items.empty?
      target, item = monkey.inspect_item
      monkeys[target].items << item
    end

    # puts "After Monkey #{monkey.name}'s turn:"
    # print_monkeys(monkeys)
  end

  puts "== After round #{i + 1} =="

  # print_monkeys(monkeys)

  monkeys.each do |monkey|
    puts "Monkey #{monkey.name} inspected items #{monkey.inspections} times."
  end
  puts ''
end

inspections = monkeys.map(&:inspections).sort.reverse
monkey_business = inspections[0] * inspections[1]

puts "\nMonkey business: #{monkey_business}"
