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
      compare_lists(other.value)
    end
  end

  def to_s
    value.inspect
  end

  protected

  def compare_lists(other_value)
    list = Array(value.clone)
    other_list = Array(other_value.clone)
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

packets = input.reject { |line| line.strip.empty? }.map { |value| Packet.new(JSON.parse(value)) }

dividers = [Packet.new([[2]]), Packet.new([[6]])]
packets += dividers

sorted_packets = packets.sort
sorted_packets.each { |p| puts p }

decoder_key = dividers.inject(1) do |product, divider|
  product * (sorted_packets.index(divider) + 1)
end

puts "Decoder key: #{decoder_key}"
