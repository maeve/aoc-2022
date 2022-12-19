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

  def can_open?
    flow_rate.positive?
  end
end

class ValveGraph
  attr_accessor :valve_map, :distance, :next_node, :start

  def initialize(input)
    parse_input(input)
    self.start = valve_map['AA']

    num_valves = valve_map.size
    self.distance = Matrix.build(num_valves, num_valves) { Float::INFINITY }
    self.next_node = Matrix.build(num_valves, num_valves) { nil }
  end

  def num_valves
    @num_valves ||= valve_map.size
  end

  def release_pressure
    compute_distances

    valve_map.each_value |
    shortest_path = path(start, valve_map['CC'])
  end

  private

  def compute_distances
    # Floyd-Warshall to compute paths between each combination of vertices
    valve_map.each_value do |valve|
      valve.tunnels.each do |neighbor|
        distance[valve.id, neighbor.id] = neighbor.can_open? ? 2 : 1
        next_node[valve.id, neighbor.id] = neighbor
      end

      distance[valve.id, valve.id] = 0
      next_node[valve.id, valve.id] = valve
    end

    num_valves.times do |k|
      num_valves.times do |i|
        num_valves.times do |j|
          if distance[i, j] > distance[i, k] + distance[k, j]
            distance[i, j] = distance[i, k] = distance[k, j]
            next_node[i, j] = next_node[i, k]
          end
        end
      end
    end
  end

  def path(valve, other_valve)
    return [] if next_node[valve.id, other_valve.id].nil?

    path = [valve]

    while valve.id != other_valve.id
      valve = next_node[valve.id, other_valve.id]
      path << valve
    end

    path
  end

  def parse_input(lines)
    self.valve_map = {}

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
    valve_map[name] ||= Valve.new(name)
  end
end

input = File.readlines('./test-input.txt').map(&:chomp)

g = ValveGraph.new(input)

shortest_path = g.release_pressure

puts shortest_path
