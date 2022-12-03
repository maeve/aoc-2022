#!/usr/bin/env ruby

rucksacks = File.readlines('./input.txt').map(&:chomp)

dictionary = ("a".."z").to_a + ("A".."Z").to_a

total = rucksacks.inject(0) do |sum, contents|
  puts "Contents: #{contents}"

  size = contents.length / 2

  left = contents.slice(0, size).split("")
  right = contents.slice(size, size).split("")

  common_items = left & right

  puts "Common items: #{common_items}"

  priorities = common_items.map { |i| dictionary.index(i) + 1 }

  puts "Priorities: #{priorities}"

  
  sum + priorities.sum
end

puts "Total: #{total}"
