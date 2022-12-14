#!/usr/bin/env ruby

require 'matrix'

class HeightMap
  attr_reader :grid, :graph, :start, :finish, :nodes, :distance

  def initialize(lines)
    @grid = Matrix[*lines.map(&:chars)]
    @graph = {}
    @nodes = []
    @distance = Hash.new(Float::INFINITY)

    build_graph
  end

  # http://en.wikipedia.org/wiki/Dijkstra's_algorithm
  def shortest_path
    current = start
    distance[start] = 0

    until current == finish
      visit_node(current)
      puts "Visited #{current}"
      current = next_node
      puts "Next node: #{current}"
    end

    distance[finish]
  end

  protected

  def visited?(node)
    !nodes.include?(node)
  end

  def visit_node(node)
    graph[node]&.each_key do |neighbor|
      next if visited?(neighbor)
      new_distance = distance[node] + 1
      distance[neighbor] = new_distance if new_distance < distance[neighbor]
    end

    nodes.delete(node)
  end

  def next_node
    min_distance = distance.reject { |node, _| visited?(node) }.values.min
    distance.select { |node, value| value == min_distance && !visited?(node) }.keys.first
  end

  def build_graph
    grid.each_with_index do |_, row, col|
      node = [row, col]
      nodes << node
      mark_endpoint(node)

      add_edge(node, [row - 1, col]) if row.positive?
      add_edge(node, [row + 1, col]) if row < grid.row_count - 1
      add_edge(node, [row, col - 1]) if col.positive?
      add_edge(node, [row, col + 1]) if col < grid.column_count - 1
    end
  end

  def mark_endpoint(node)
    case grid[*node]
    when 'S' then @start = node
    when 'E' then @finish = node
    end
  end

  def add_edge(source, target)
    source_height = height(grid[*source])
    target_height = height(grid[*target])

    return unless target_height <= source_height + 1

    graph[source] ||= {}
    graph[source][target] = target_height - source_height
  end

  def height(char)
    char = case char
           when 'S' then 'a'
           when 'E' then 'z'
           else char
           end

    char.bytes.first - 96
  end
end

input = File.readlines('./input.txt').map(&:chomp)
map = HeightMap.new(input)

puts "Shortest path: #{map.shortest_path} steps"
