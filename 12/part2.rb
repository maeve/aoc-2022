#!/usr/bin/env ruby

require 'matrix'

class Node
  attr_reader :row, :col, :code
  attr_accessor :g_score, :f_score, :edges

  def initialize(row, col, code)
    @row = row
    @col = col
    @code = code

    self.f_score = Float::INFINITY
    self.g_score = Float::INFINITY
    self.edges = []
  end

  def start?
    height == 1
  end

  def finish?
    code == 'E'
  end

  def height
    return @height if @height

    char = case code
           when 'S' then 'a'
           when 'E' then 'z'
           else code
           end

    @height = char.bytes.first - 96
  end

  def coord
    [row, col]
  end

  def to_s
    "{coord=#{coord.inspect}, code=#{code}, height=#{height}, edges=[#{edges.map(&:coord).inspect}]}"
  end
end

class HeightMap
  attr_reader :grid, :open_set, :finish

  def initialize(lines)
    @grid = Matrix.build(lines.length, lines[0].length) do |row, col|
      Node.new(row, col, lines[row][col])
    end
    @open_set = []

    build_graph
    init_open_set
  end

  # See https://en.wikipedia.org/wiki/A*_search_algorithm
  def shortest_path
    until open_set.empty?
      current = next_node
      return current.g_score if current.finish?
      open_set.delete(current)

      current.edges.each do |neighbor|
        score_node(neighbor, current.g_score)
      end
    end

    finish.g_score
  end

  protected

  def init_open_set
    open_set.each do |start|
      start.g_score = 0
      start.f_score = heuristic(start)
    end
  end

  def score_node(node, g_score)
    new_g_score = g_score + 1
    return unless new_g_score < node.g_score

    node.g_score = new_g_score
    node.f_score = new_g_score + heuristic(node)
    open_set << node unless open_set.include?(node)
  end

  def next_node
    min_f_score = open_set.map(&:f_score).min
    open_set.detect { |node| node.f_score == min_f_score }
  end

  def heuristic(node)
    (finish.row - node.row) +
      (finish.col - node.col)
  end

  def build_graph
    grid.each do |node|
      mark_endpoint(node)

      add_up(node)
      add_down(node)
      add_left(node)
      add_right(node)
    end
  end

  def mark_endpoint(node)
    if node.start?
      open_set << node
    elsif node.finish?
      @finish = node
    end
  end

  def add_up(node)
    add_edge(node, grid[node.row - 1, node.col]) if node.row.positive?
  end

  def add_down(node)
    add_edge(node, grid[node.row + 1, node.col]) if node.row < grid.row_count - 1
  end

  def add_left(node)
    add_edge(node, grid[node.row, node.col - 1]) if node.col.positive?
  end

  def add_right(node)
    add_edge(node, grid[node.row, node.col + 1]) if node.col < grid.column_count - 1
  end

  def add_edge(source, target)
    source.edges << target if target.height <= source.height + 1
  end
end

input = File.readlines('./input.txt').map(&:chomp)
map = HeightMap.new(input)

puts "Shortest path: #{map.shortest_path} steps"
