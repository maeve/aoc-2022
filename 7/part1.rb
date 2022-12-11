#!/usr/bin/env ruby

input = File.readlines('./input.txt').map(&:chomp)

module Elf
  class Fs
    attr_accessor :parent
    attr_reader :name

    def initialize(name)
      @name = name
    end

    def self.create(input)
      segments = input.strip.split(" ")

      if segments[0] == "dir"
        Dir.new(segments[1])
      else
        File.new(segments[1], segments[0])
      end
    end

    def to_s
      "- #{name} (#{type}, size=#{size})"
    end

    def to_tree(indent = 0)
      "#{' ' * indent}#{self}\n"
    end
  end

  class File < Fs
    attr_reader :size

    def initialize(name, size)
      super(name)
      @size = size.to_i
    end

    def type
      "file"
    end

  end

  class Dir < Fs
    attr_reader :children

    def initialize(name)
      super(name)
      @children = []
    end

    def cd(dir_name)
      new_dir = nil

      if dir_name == '..'
        new_dir = parent
      elsif dir_name == '/'
        new_dir = self
        new_dir = new_dir.parent until new_dir.parent.nil?
      else
        new_dir = children.detect { |c| c.is_a?(Dir) && c.name == dir_name }
      end

      new_dir
    end

    def <<(child)
      child.parent = self
      children << child
    end

    def type
      "dir"
    end

    def to_tree(indent = 0)
      tree = super

      indent += 2

      children.each do |child|
        tree += child.to_tree(indent)
      end

      tree
    end

    def size
      children.map(&:size).inject(:+)
    end

    def dirs
      result = [self]
      result += children.select { |c| c.is_a?(Dir) }.map(&:dirs)
      result.flatten
    end
  end
end

cwd = Elf::Fs.create('dir /')

input.each do |line|
  if (match = line.match(/^\$ cd ([\/\.a-z]+)/))
    cwd = cwd.cd(match[1])
  elsif line !~ /^\$ ls/
    cwd << Elf::Fs.create(line)
  end
end

root = cwd.cd("/")

puts root.to_tree

dirs = root.dirs.select { |d| d.size <= 100000 }
puts "Dirs: #{dirs.map(&:name)}"
puts "Sum: #{dirs.map(&:size).sum}"
