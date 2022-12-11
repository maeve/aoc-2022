#!/usr/bin/env ruby

require 'matrix'

input = File.readlines('./input.txt').map(&:chomp)

trees = Matrix.rows(input.map { |line| line.split('').map(&:to_i) })

scenic_scores = Matrix.build(trees.row_count, trees.column_count) do |row, col|
  tree = trees[row, col]
  row_trees = trees.row(row)
  col_trees = trees.column(col)

  left = if col.zero?
           0
         else
           blocker = row_trees[0..(col - 1)].rindex { |t| t >= tree }.to_i
           col - blocker
         end

  right = if col == trees.column_count - 1
            0
          else
            right_trees = row_trees[(col + 1)..]

            if (index = right_trees.index { |t| t >= tree })
              index + 1
            else
              right_trees.length
            end
          end

  up = if row.zero?
         0
       else
         blocker = col_trees[0..(row - 1)].rindex { |t| t >= tree }.to_i
         row - blocker
       end

  down = if row == trees.row_count - 1
           0
         else
           down_trees = col_trees[(row + 1)..]

           if (index = down_trees.index { |t| t >= tree })
             index + 1
           else
             down_trees.length
           end
         end

  left * right * up * down
end

puts "Max scenic score: #{scenic_scores.max}"
