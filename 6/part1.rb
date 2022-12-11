#!/usr/bin/env ruby

input = File.readlines('./input.txt').map(&:chomp)

stacks = Array.new(10)

input.each do |line|
  line.chars.each_index do |i|
    segment = line.chars.slice(i, 4)

    if segment == segment.uniq
      puts "Characters: #{i + 4}"
      break
    end
  end
end
