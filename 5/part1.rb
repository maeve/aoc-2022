#!/usr/bin/env ruby

input = File.readlines('./input.txt').map(&:chomp)

stacks = Array.new(10)

input.each do |line|
  if line =~ /\[[A-Z]\]/
    stack_num = 0

    line.chars.each_slice(4) do |segment|
      stack_num += 1
      if segment[0] == '['
        stacks[stack_num] ||= []
        stacks[stack_num].unshift(segment[1])
      end
    end
  elsif (match = line.match(/move ([0-9]+) from ([0-9]+) to ([0-9]+)/))
    count, src, dest = match[1..3].map(&:to_i)
    stacks[dest] += stacks[src].pop(count).reverse
  end
end

puts "Stacks: #{stacks}"

puts "Code: #{stacks.compact.map(&:last).join('')}"
