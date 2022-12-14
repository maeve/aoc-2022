#!/usr/bin/env ruby

require 'matrix'

class HeightMap
  attr_reader :grid, :graph, :start, :finish

  def initialize(lines)
    @grid = Matrix[*lines.map(&:chars)]
    @graph = {}

    build_graph
  end

  # See https://en.wikipedia.org/wiki/A*_search_algorithm
  def shortest_path
    open_set = [start]

    g_score = Hash.new(Float::INFINITY)
    g_score[start] = 0

    f_score = Hash.new(Float::INFINITY)
    f_score[start] = heuristic(start)

    until open_set.empty?
      min_f_score = f_score.select { |key, _| open_set.include?(key) }.values.min
      current = f_score.detect { |key, value| value == min_f_score && open_set.include?(key) }.first

      return g_score[current] if current == finish

      open_set.delete(current)

      graph[current].each_key do |neighbor|
        new_g_score = g_score[current] + 1
        if new_g_score < g_score[neighbor]
          g_score[neighbor] = new_g_score
          f_score[neighbor] = new_g_score + heuristic(neighbor) 
          open_set << neighbor unless open_set.include?(neighbor)
        end
      end
    end
  end

  protected

  def heuristic(node)
    (finish[0] - node[0]) +
      (finish[1] - node[1])
  end

  def build_graph
    grid.each_with_index do |_, row, col|
      node = [row, col]
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
