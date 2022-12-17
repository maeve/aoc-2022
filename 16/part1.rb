#!/usr/bin/env ruby
# frozen_string_literal: true

class Valve
  attr_accessor :name, :flow_rate, :tunnels, :closed

  def initialize(name)
    self.name = name
    self.closed = true
  end

  def open?
    !closed
  end

  def closed?
    closed
  end

  def open
    self.closed = false
  end

  def to_s
    "Valve #{name} has flow rate=#{flow_rate}; tunnels lead to #{tunnels.map(&:name).join(', ')}"
  end
end

class ValveGraph
  attr_accessor :valves, :time_remaining

  def initialize(input)
    self.valves = {}
    parse_input(input)
    self.time_remaining = 30
  end

  def minute
    31 - time_remaining
  end

  def release_pressure
    current = valves['AA']

    until time_remaining.zero?
      print_status

      if current.flow_rate.zero? || current.open?
        tunnel = current.tunnels.select(&:closed).sort_by(&:flow_rate).last
        puts "You move to valve #{tunnel.name}."
        current = tunnel
      elsif current.closed?
        puts "You open valve #{current.name}."
        current.open
      end

      puts ''

      self.time_remaining -= 1
    end
  end

  def print_status
    puts "== Minute #{31 - time_remaining} =="

    if open_valves.empty?
      puts 'No valves are open.'
    else
      puts "Valves #{open_valves.map(&:name).join(', ')} are open, releasing #{total_flow_rate} pressure."
    end
  end

  private

  def open_valves
    valves.values.select(&:open?)
  end

  def total_flow_rate
    open_valves.map(&:flow_rate).inject(:+)
  end

  def parse_input(lines)
    lines.each do |line|
      matches = line.match(
        /Valve (?<name>[A-Z]+) has flow rate=(?<flow_rate>[0-9]+); tunnels? leads? to valves? (?<tunnels>.*)/
      )

      valve = find_or_create_valve(matches[:name])
      valve.flow_rate = matches[:flow_rate].to_i
      valve.tunnels = matches[:tunnels].split(', ').map { |t| find_or_create_valve(t) }
    end
  end

  def find_or_create_valve(name)
    valves[name] ||= Valve.new(name)
  end
end

input = File.readlines('./test-input.txt').map(&:chomp)

g = ValveGraph.new(input)

g.release_pressure
