# frozen_string_literal: true

require_relative "lib/rfc_reader/version"

Gem::Specification.new do |spec|
  spec.name = "rfc-reader"
  spec.version = RfcReader::VERSION
  spec.authors = ["Kevin Robell"]
  spec.email = ["apainintheneck@gmail.com"]

  spec.summary = "Search for and read RFCs at the command line."
  spec.homepage = "https://github.com/apainintheneck/rfc-reader/"
  spec.license = "MIT"
  spec.required_ruby_version = ">= 3.0.0"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = spec.homepage
  spec.metadata["changelog_uri"] = File.join(spec.homepage, "blob/main/CHANELOG.md")
  spec.metadata["rubygems_mfa_required"] = "true"

  spec.files = Dir["{lib,exe}/**/*"]
  spec.bindir = "exe"
  spec.executables = ["rfc-reader"]

  spec.add_dependency "nokogiri", "~> 1.16"
  spec.add_dependency "rss", "~> 0.3"
  spec.add_dependency "thor", "~> 1.3"
  spec.add_dependency "tty-pager", "~> 0.14"
  spec.add_dependency "tty-prompt", "~> 0.23"
end
