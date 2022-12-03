#!/usr/bin/env ruby

rounds = File.readlines('./input.txt').map(&:chomp).map(&:split)

scores = {
  rock: 1,
  paper: 2,
  scissors: 3
}

shapes = {
  'A' => :rock,
  'B' => :paper,
  'C' => :scissors
}

outcomes = {
  'X' => :lose,
  'Y' => :draw,
  'Z' => :win
}

wins = {
  rock: :scissors,
  paper: :rock,
  scissors: :paper
}

total_score = rounds.inject(0) do |score, round|
  opponent = shapes[round[0]]
  outcome = outcomes[round[1]]

  puts "Opponent: #{opponent}"
  puts "Outcome: #{outcome}"

  mine = case outcome
         when :win
           wins.invert[opponent]
         when :lose
           wins[opponent]
         else
           opponent
         end

  puts "Mine: #{mine}"

  round_score = scores[mine]

  if wins[mine] == opponent
    round_score += 6
  elsif opponent == mine
    round_score += 3
  end

  puts "Round score: #{round_score}\n\n"

  score + round_score
end

puts "Score: #{total_score}"
