#!/usr/bin/env ruby
# frozen_string_literal: true

require 'matrix'
require 'set'

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
    @cache = {}
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

    max_pressure = 0

    puts 'Working valves'
    puts working_valves
    puts

    processed_sets = []

    working_valves.permutation(working_valves.size / 2) do |nodes|
      valve_set = Set[*nodes]
      next if processed_sets.include?(valve_set)

      processed_sets << valve_set

      pressure1 = release_valves(nodes, 26)

      remaining = working_valves - nodes
      next unless estimate_pressure(start, remaining, 26) > max_pressure - pressure1

      pressure2 = release_valves(remaining, 26)
      max_pressure = [max_pressure, pressure1 + pressure2].max
    end

    max_pressure
  end

  private

  def release_valves(nodes, time)
    stack = [[start, time, [], 0]]

    max_pressure = 0

    until stack.empty?
      valve, minutes_left, visited, pressure = stack.pop

      next if visited.include?(valve)

      minutes_left -= distance[visited.last.id, valve.id] if visited.last
      visited += [valve]
      minutes_left -= 1 if valve.working?
      pressure += valve.flow_rate * minutes_left

      max_pressure = [pressure, max_pressure].max
      unopened = (nodes - visited)

      if pressure + estimate_pressure(valve, unopened, minutes_left) >= max_pressure
        unopened.each { |v| stack.push([v, minutes_left, visited, pressure]) }
      end
    end

    max_pressure
  end

  def estimate_pressure(root, nodes, minutes_left)
    valid_nodes = [root] + nodes

    nodes.sum do |valve|
      node = valid_nodes.min_by { |v| distance[valve.id, v.id] }
      valid_nodes.delete(node)

      minutes_left -= distance[valve.id, node.id]
      valve.flow_rate * minutes_left
    end
  end

  def working_valves
    @working_valves ||= valves.values.select(&:working?).sort_by(&:flow_rate)
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

input = File.readlines('./input.txt').map(&:chomp)

g = ValveGraph.new(input)

puts "Released pressure:"
puts g.release_pressure
