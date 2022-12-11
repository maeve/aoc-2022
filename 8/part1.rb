#!/usr/bin/env ruby

require 'matrix'

input = File.readlines('./input.txt').map(&:chomp)

trees = Matrix.rows(input.map { |line| line.split('').map(&:to_i) })

visible_trees = 0

trees.each_with_index do |tree, row, col|
  if row.zero? || row == (trees.row_count - 1) ||
     col.zero? || col == (trees.column_count - 1)
    # Edge trees are always visible
    visible_trees += 1
  else
    row_trees = trees.row(row)
    col_trees = trees.column(col)

    # Are all of the trees shorter in any direction?
    if row_trees[0..(col - 1)].max < tree ||
       row_trees[(col + 1)..].max < tree ||
       col_trees[0..(row - 1)].max < tree ||
       col_trees[(row + 1)..].max < tree
      visible_trees += 1
    end

  end
end

puts "Visible trees: #{visible_trees}"
