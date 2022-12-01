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

puts "The elf with the most calories has #{elves.sort.last}"
