#!/usr/bin/env ruby
# frozen_string_literal: true

require 'matrix'

class Valve
  attr_accessor :id, :name, :flow_rate, :tunnels

  class << self
    def generate_id
      @next_id ||= -1
      @next_id += 1
    end
  end

  def initialize(name)
    self.id = self.class.generate_id
    self.name = name
  end

  def to_s
    "Valve: id=#{id} name=#{name} flow_rate=#{flow_rate} tunnels=[#{tunnels.map(&:name).join(', ')}]"
  end

  def ==(other)
    name == other.name
  end

  def eql?(other)
    self == other
  end

  def hash
    [name].hash
  end

  def working?
    flow_rate.positive?
  end
end

class ValveGraph
  attr_accessor :valves, :distance

  def initialize(input)
    parse_input(input)
    self.distance = Matrix.build(valves.size, valves.size) { Float::INFINITY }
  end

  def start
    valves['AA']
  end

  def release_pressure
    compute_distances

    puts "Working valves: #{working_valves.size}"
    puts working_valves

    max_pressure = 0

    working_valves.permutation do |path|
      path.unshift(start)
      max_pressure = [released_pressure(path), max_pressure].max
    end

    max_pressure
  end

  private

  def working_valves
    @working_valves ||= valves.values.select(&:working?).sort_by(&:flow_rate).reverse
  end

  def released_pressure(path)
    minutes_left = 30
    pressure = 0

    path.each_cons(2) do |prev, node|
      minutes_left -= distance[prev.id, node.id]

      minutes_left -= 1 if node.working?
      pressure += node.flow_rate * minutes_left
    end

    pressure
  end

  def compute_distances
    # Floyd-Warshall to compute paths between each combination of vertices
    valves.each_value do |valve|
      valve.tunnels.each do |neighbor|
        distance[valve.id, neighbor.id] = 1
      end

      if valve.working?
        distance[valve.id, valve.id] = valve.working? ? 1 : 0
      end
    end

    valves.size.times do |k|
      valves.size.times do |i|
        valves.size.times do |j|
          if distance[i, j] > distance[i, k] + distance[k, j]
            distance[i, j] = distance[i, k] + distance[k, j]
          end
        end
      end
    end
  end

  def parse_input(lines)
    self.valves = {}

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

puts "Released pressure:"
puts g.release_pressure
