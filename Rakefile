# frozen_string_literal: true

require "bundler/gem_tasks"
require "rubocop/rake_task"

RuboCop::RakeTask.new

task default: %i[lint spec]

desc "Shortcut for `rake rubocop`"
task lint: :rubocop

desc "Shortcut for `rake rubocop:autocorrect`"
task fix: :"rubocop:autocorrect"

desc "Shortcut for `rspec`."
task :spec do
  sh "bundle", "exec", "rspec"
end

namespace "spec" do
  desc "Shortcut for `rspec --tag online`"
  task :online do
    sh "bundle", "exec", "rspec", "--tag", "online"
  end
end
