#!/usr/bin/env ruby

input = File.readlines('./input.txt').map(&:chomp)

elves = [0]

input.each do |line|
  if line.empty?
    elves << 0
  else
    elves[-1] += line.to_i
  end
end

top_elves = elves.sort.reverse.slice(0..2)

puts "Top elves: #{top_elves}"
puts "sum: #{top_elves.sum}"
