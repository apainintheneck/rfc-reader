# frozen_string_literal: true

require "bundler/gem_tasks"
require "standard/rake"
require "rspec/core/rake_task"

RSpec::Core::RakeTask.new(:spec)

task default: %i[standard spec lint:ruby_version]

namespace "lint" do
  desc "Check the minimum version matches between .standard.yml and *.gemspec"
  task :ruby_version do
    sh "bundle exec ruby script/lint_ruby_version.rb"
  end
end
