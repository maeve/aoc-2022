#!/usr/bin/env ruby
# frozen_string_literal: true

class State
  RESOURCE_TYPES = [:geode, :obsidian, :clay, :ore].freeze

  attr_accessor :costs, :producers, :resources, :minutes_left

  def initialize(
    costs:,
    producers: { ore: 1, clay: 0, obsidian: 0, geode: 0 },
    resources: { ore: 0, clay: 0, obsidian: 0, geode: 0 },
    minutes_left: 24
  )
    self.costs = costs
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
        # Always build a geode robot when we can
        (robot_type == :geode ||
         # We can only produce one robot at a time, so don't bother generating
         # excess resources
         producers[robot_type] < max_cost(robot_type))
    end
  end

  def max_cost(resource_type)
    costs.map { |_, values| values[resource_type].to_i }.max
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

  class << self
    def advance_from(previous_state)
      new(costs: previous_state.costs,
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

  def quality_level
    @quality_level ||= id * max_geodes
  end

  def max_geodes
    return @max_geodes unless @max_geodes.nil?

    queue = [State.new(costs: costs)]

    @max_geodes = 0

    until queue.empty?
      state = queue.shift

      next if state.finished?

      # puts "Processing state"
      # puts state

      pending = state.affordable_robots

      state.collect_resources

      # Prune search space to find max
      next if state.resources[:geode] < @max_geodes

      @max_geodes = state.resources[:geode]
      # puts "Max geodes: #{@max_geodes}"

      # We always have the option to build nothing and collect resources
      queue << State.advance_from(state)

      pending.each do |resource_type|
        next_state = State.advance_from(state)
        next_state.add_robot(resource_type)
        queue << next_state
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
      quality = blueprint.quality_level
      puts "Quality level for blueprint id=#{blueprint.id} is #{quality}"
      quality
    end.sum
  end
end

input = File.readlines('./test-input.txt').map(&:chomp)

puts RobotFactory.new(input).total_quality_level
