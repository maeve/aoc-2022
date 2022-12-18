#!/usr/bin/env ruby
# frozen_string_literal: true

class Valve
  attr_accessor :name, :flow_rate, :tunnels

  def initialize(name)
    self.name = name
  end

  def to_s
    "Valve #{name} has flow rate=#{flow_rate}; tunnels lead to #{tunnels.map(&:name).join(', ')}"
  end
end

class ValvePath
  attr_accessor :valve, :pressure, :opened, :visited

  def initialize(valve, pressure, opened = [], visited = [])
    self.valve = valve
    self.pressure = pressure
    self.opened = opened
    self.visited = visited

    # No-flow valves are the same open or closed, so consider them open
    visit!
    open! if valve.flow_rate.zero? && !open?
  end

  def update_pressure
    self.pressure += opened.map(&:flow_rate).inject(:+).to_i
  end

  def open?
    opened.include?(valve)
  end

  def visit!
    visited << valve
    self
  end

  def open!
    opened << valve unless open?
    self
  end

  def adjacent_paths
    valve.tunnels.map do |neighbor|
      ValvePath.new(neighbor, pressure, opened.clone, visited.clone)
    end
  end

  def all_open?(valves)
    (valves - opened).empty?
  end

  def to_s
    "valve=#{valve.name} pressure=#{pressure} opened=#{opened.map(&:name).inspect} visited=#{visited.map(&:name).inspect}"
  end
end

class ValveGraph
  attr_accessor :valves, :time_remaining

  def initialize(input)
    self.valves = {}
    self.time_remaining = 30
    parse_input(input)
  end

  def release_pressure
    max_path = ValvePath.new(valves['AA'], 0)
    paths = [max_path]


    until time_remaining.zero?
      next_step = []

      puts "=== Minute: #{31 - time_remaining} =="
      puts

      until paths.empty?
        path = paths.shift
        path.update_pressure
        max_path = path if path.pressure > max_path.pressure

        if path.all_open?(valves.values)
          next_step << path
        elsif path.open?
          next_step += path.adjacent_paths
        else
          next_step << path.open!
        end

      end

      puts "max_path: #{max_path}"
      puts

      paths = next_step
      self.time_remaining -= 1
    end

    max_path
  end

  private

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

puts "Released pressure: #{g.release_pressure}"
