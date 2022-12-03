#!/usr/bin/env ruby

rounds = File.readlines('./input.txt').map(&:chomp).map(&:split)

element_scores = {
  rock: 1,
  paper: 2,
  scissors: 3
}

element_encoding = {
  'A' => :rock,
  'B' => :paper,
  'C' => :scissors,
  'X' => :rock,
  'Y' => :paper,
  'Z' => :scissors
}

score = rounds.inject(0) do |score, round|
  opponent = element_encoding[round[0]]
  mine = element_encoding[round[1]]

  round_score = element_scores[mine]

  if (mine == :rock && opponent == :scissors) ||
      (mine == :paper && opponent == :rock) ||
      (mine == :scissors && opponent == :paper)
    round_score += 6
  elsif opponent == mine
    round_score += 3
  end

  puts "Round score: #{round_score}"

  score + round_score
end

puts "Score: #{score}"
