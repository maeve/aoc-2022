#!/usr/bin/env ruby

require 'json'

def correct_order?(value, other_value, depth=0)
  indent = "  " * depth

  left_arr = Array(value)
  right_arr = Array(other_value)

  left_arr << nil if left_arr.size < right_arr.size

  left_arr.zip(right_arr).each do |left, right|
    puts "#{indent}- Compare #{left} vs #{right}"
    next if left == right

    if left.nil?
      puts "#{indent}  - Left side ran out of items, so inputs are in the right order"
      return true
    elsif right.nil?
      puts "#{indent}  - Right side ran out of items, so inputs are NOT in the right order"
      return false
    elsif left.is_a?(Array) || right.is_a?(Array)
      return correct_order?(left, right, depth + 1)
    elsif left < right
      puts "#{indent}  - Left side is smaller, so inputs are in the right order"
      return true
    elsif left > right
      puts "#{indent}  - Right side is smaller, so inputs are NOT in the right order"
      return false
    end
  end
end

input = File.readlines('./input.txt').map(&:chomp)

index = 0
sum = 0

input.each_slice(3) do |pair|
  left = JSON.parse(pair[0])
  right = JSON.parse(pair[1])

  puts "== Pair #{index += 1} =="
  puts "- Compare #{left.to_json} vs #{right.to_json}"
  sum += index if correct_order?(left, right)
end

puts "Sum: #{sum}"
