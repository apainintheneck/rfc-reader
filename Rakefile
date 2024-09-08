# frozen_string_literal: true

require "bundler/gem_tasks"

Minitest::TestTask.create

require "rubocop/rake_task"

RuboCop::RakeTask.new

task default: %i[test rubocop]
