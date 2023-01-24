#!/usr/bin/env ruby
# frozen_string_literal: true

class State
  RESOURCE_TYPES = %i[geode obsidian clay ore].freeze

  attr_accessor :costs, :max_costs, :producers, :resources, :minutes_left

  def initialize(
    costs:,
    max_costs: nil,
    producers: { ore: 1, clay: 0, obsidian: 0, geode: 0 },
    resources: { ore: 0, clay: 0, obsidian: 0, geode: 0 },
    minutes_left: 32
  )
    self.costs = costs

    unless max_costs
      max_costs = { ore: 0, clay: 0, obsidian: 0, geode: Float::INFINITY }

      costs.each_pair do |_, resource_costs|
        resource_costs.each_key do |resource_type|
          max_costs[resource_type] = [max_costs[resource_type], resource_costs[resource_type]].max
        end
      end
    end

    self.max_costs = max_costs
    self.producers = producers.clone
    self.resources = resources.clone
    self.minutes_left = minutes_left
  end

  def collect_resources
    producers.each_pair do |resource_type, count|
      resources[resource_type] += count
    end
  end

  def affordable_robots
    RESOURCE_TYPES.select do |robot_type|
      can_afford?(robot_type) &&
         # We can only produce one robot at a time, so don't bother generating
         # excess resources
         producers[robot_type] < max_costs[robot_type] &&
         resources[robot_type] / 2 < max_costs[robot_type]
    end
  end

  def can_afford?(resource_type)
    costs[resource_type].all? { |cost_type, cost| resources[cost_type] >= cost }
  end

  def add_robot(resource_type)
    return unless can_afford?(resource_type)

    producers[resource_type] += 1
    costs[resource_type].each { |cost_type, cost| resources[cost_type] -= cost }
  end

  def finished?
    minutes_left.zero?
  end

  def to_s
    "producers=#{producers.inspect} resources=#{resources.inspect} minutes_left=#{minutes_left}"
  end

  def estimated_max_geodes
    resources[:geode] +
      producers[:geode] * minutes_left +
      # Fudge factor so we don't prune too early - what if we produced a new
      # geode robot every minute
      (1..minutes_left).sum
  end

  class << self
    def advance_from(previous_state)
      new(costs: previous_state.costs,
          max_costs: previous_state.max_costs,
          producers: previous_state.producers,
          resources: previous_state.resources,
          minutes_left: previous_state.minutes_left - 1)
    end
  end
end

class Blueprint
  RESOURCE_TYPES = [:geode, :obsidian, :clay, :ore].freeze

  attr_accessor :id, :costs, :states

  def initialize(input)
    matches = input.match(/Blueprint (?<id>[0-9]+): Each ore robot costs (?<or_ore_cost>[0-9]+) ore. Each clay robot costs (?<cr_ore_cost>[0-9]+) ore. Each obsidian robot costs (?<obr_ore_cost>[0-9]+) ore and (?<obr_clay_cost>[0-9]+) clay. Each geode robot costs (?<gr_ore_cost>[0-9]+) ore and (?<gr_obsidian_cost>[0-9]+) obsidian./)

    self.id = matches[:id].to_i
    self.costs = {
      ore: { ore: matches[:or_ore_cost].to_i },
      clay: { ore: matches[:cr_ore_cost].to_i },
      obsidian: { ore: matches[:obr_ore_cost].to_i, clay: matches[:obr_clay_cost].to_i },
      geode: { ore: matches[:gr_ore_cost].to_i, obsidian: matches[:gr_obsidian_cost].to_i }
    }
  end

  def max_geodes
    return @max_geodes unless @max_geodes.nil?

    states = [State.new(costs: costs)]

    @max_geodes = 0

    until states.empty?
      state = states.pop

      next if state.finished? || state.estimated_max_geodes < @max_geodes

      pending = state.affordable_robots

      state.collect_resources

      @max_geodes = [state.resources[:geode], @max_geodes].max

      # We always have the option to build nothing and collect resources
      states << State.advance_from(state)

      pending.each do |resource_type|
        next_state = State.advance_from(state)
        next_state.add_robot(resource_type)
        states << next_state
      end
    end

    @max_geodes
  end
end

class RobotFactory
  attr_accessor :blueprints

  def initialize(input)
    self.blueprints = input.map { |line| Blueprint.new(line) }
  end

  def total_quality_level
    blueprints.map do |blueprint|
      max_geodes = blueprint.max_geodes
      puts "Max geodes for blueprint id=#{blueprint.id} is #{max_geodes}"
      max_geodes
    end.inject(:*)
  end
end

input = File.readlines('./input.txt').map(&:chomp).slice(0, 3)

puts RobotFactory.new(input).total_quality_level
