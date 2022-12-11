#!/usr/bin/env ruby

input = File.readlines('./input.txt').map(&:chomp)

class Monkey
  attr_reader :name, 
              :items, 
              :operation, 
              :operand,
              :test,
              :outcomes,
              :inspections

  def initialize(lines)
    self.name = lines[0]
    self.items = lines[1]
    self.operation = lines[2]
    self.test = lines[3]

    @outcomes = {
      true => target_monkey(split_line(lines[4]).last),
      false => target_monkey(split_line(lines[5]).last),
    }

    @inspections = 0
  end

  def inspect
    item = items.shift

    item = item.send(operation, operand_for(item))
    item = (item.to_f / 3.0).to_i

    target = outcomes[item % test == 0]

    @inspections += 1

    [target, item]
  end

  def to_s
    "Monkey #{name}: #{items.join(', ') }"
  end

  private

  def name=(line)
    @name = split_line(line).first.match(/Monkey ([0-9]+)/)[1]
  end

  def items=(line)
    @items = split_line(line).last.split(',').map(&:to_i)
  end

  def operation=(line)
    match = split_line(line).last.match(/new = old (.) ([[0-9a-z]]+)/)
    @operation = match[1].to_sym
    @operand = match[2] == 'old' ? :old : match[2].to_i
  end

  def test=(line)
    @test = split_line(line).last.match(/divisible by ([0-9]+)/)[1].to_i
  end

  def split_line(line)
    line.split(':').map(&:strip)
  end

  def target_monkey(string)
    string.match(/throw to monkey ([0-9]+)/)[1].to_i
  end

  def operand_for(value)
    if operand == :old
      value
    else
      operand.to_i
    end
  end
end

monkeys = []

input.each_slice(7) do |lines|
  monkeys << Monkey.new(lines)
end

20.times do |i|
  monkeys.each do |monkey|
    until monkey.items.empty?
      target, item = monkey.inspect
      monkeys[target].items << item
    end
  end

  puts "After round #{i + 1}, the monkeys are holding items with these worry levels:"
  monkeys.each { |m| puts m }
  puts ''
end

monkeys.each do |monkey|
  puts "Monkey #{monkey.name} inspected items #{monkey.inspections} times."
end

inspections = monkeys.map(&:inspections).sort.reverse
monkey_business = inspections[0] * inspections[1]

puts "\nMonkey business: #{monkey_business}"
