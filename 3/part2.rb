#!/usr/bin/env ruby

rucksacks = File.readlines('./input.txt').map(&:chomp)

dictionary = ("a".."z").to_a + ("A".."Z").to_a

total = 0

rucksacks.each_slice(3) do |group|
  common_items = group.map { |g| g.split("") }.inject(:&)
  priorities = common_items.map { |i| dictionary.index(i) + 1 }
  total += priorities.sum
end

puts "Total: #{total}"
