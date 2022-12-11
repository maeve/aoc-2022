#!/usr/bin/env ruby

section_assignments = File.readlines('./input.txt').map(&:chomp)

contained_pairs = []

section_assignments.each do |input|
  sections = input.split(",").map { |section| section.split("-").map(&:to_i) }.map { |pair| (pair[0]..pair[1]).to_a }

  contained_pairs << input unless sections.inject(:&).empty?
end

puts "Overlapping pairs:\n#{contained_pairs.join("\n")}"
puts "Total overlapping pairs: #{contained_pairs.size}"

