#!/usr/bin/env ruby

input = File.readlines('./input.txt').map(&:chomp)

input.each do |line|
  line.chars.each_index do |i|
    segment = line.chars.slice(i, 14)

    if segment == segment.uniq
      puts "Characters: #{i + 14}"
      break
    end
  end
end
