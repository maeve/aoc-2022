#!/usr/bin/env ruby

require 'json'

class Packet
  include Comparable

  attr_accessor :value

  def initialize(value)
    self.value = value
  end

  def <=>(other)
    if value.nil? && other.value.nil?
      0
    elsif value.nil?
      -1
    elsif other.value.nil?
      1
    elsif value.is_a?(Integer) && other.value.is_a?(Integer)
      value <=> other.value
    else
      compare_lists(Array(value), Array(other.value))
    end
  end

  protected

  def compare_lists(list, other_list)
    list << nil if list.length < other_list.length

    result = 0

    list.zip(other_list).each do |left, right|
      result = Packet.new(left) <=> Packet.new(right)
      break unless result.zero?
    end

    result
  end
end

input = File.readlines('./input.txt').map(&:chomp)

pair_index = 0
sum = 0

input.each_slice(3) do |pair|
  pair_index += 1
  left = JSON.parse(pair[0])
  right = JSON.parse(pair[1])

  if Packet.new(left) < Packet.new(right)
    puts "Adding pair #{pair_index} to sum"
    sum += pair_index
  end
end

puts "Sum: #{sum}"
