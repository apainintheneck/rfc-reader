# frozen_string_literal: true

require "fileutils"
require "json"
require "net/http"

module RfcReader
  module Library
    MAX_DOCUMENT_COUNT = 100
    private_constant :MAX_DOCUMENT_COUNT

    XDG_CACHE_HOME = ENV
      .fetch("XDG_CACHE_HOME") { File.join(Dir.home, ".cache") }
      .then { |path| File.expand_path(path) }
      .freeze
    private_constant :XDG_CACHE_HOME

    PROGRAM_CACHE_DIR = File.join(XDG_CACHE_HOME, "rfc_reader").freeze
    private_constant :PROGRAM_CACHE_DIR

    LIBRARY_CACHE_LIST_PATH = File.join(PROGRAM_CACHE_DIR, "library_list.json").freeze
    private_constant :LIBRARY_CACHE_LIST_PATH

    LIBRARY_CACHE_DIR = File.join(PROGRAM_CACHE_DIR, "library").freeze
    private_constant :LIBRARY_CACHE_DIR

    def self.download_document(title:, url:)
      file_name = File.basename(url)
      file_path = File.join(LIBRARY_CACHE_DIR, file_name)

      content = Net::HTTP.get(URI(url))
      FileUtils.mkdir_p(LIBRARY_CACHE_DIR)
      File.write(file_path, content)
      add_to_catalog(title: title, url: url, path: file_path)

      content
    end

    def self.load_document(title:, url:, path:)
      content = File.read(path)

      add_to_catalog(title: title, url: url, path: path)

      content
    end

    def self.catalog
      if File.exist?(LIBRARY_CACHE_LIST_PATH)
        content = File.read(LIBRARY_CACHE_LIST_PATH)
        JSON.parse(content, symbolize_names: true)
      else
        []
      end
    end

    def self.add_to_catalog(title:, url:, path:)
      list = catalog.reject do |rfc|
        title == rfc[:title] ||
          url == rfc[:url] ||
          path == rfc[:path]
      end

      rfc = {
        title: title,
        url: url,
        path: path,
      }

      list = [rfc, *list]
      while list.size > MAX_DOCUMENT_COUNT
        path = list.pop[:path]
        FileUtils.rm_f(path) if path.start_with?(LIBRARY_CACHE_DIR)
      end

      json = JSON.pretty_generate(list)
      FileUtils.mkdir_p(PROGRAM_CACHE_DIR)
      File.write(LIBRARY_CACHE_LIST_PATH, json)
    end
  end
end
