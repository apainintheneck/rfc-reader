# frozen_string_literal: true

require "fileutils"
require "json"
require "net/http"

module RfcReader
  module Library
    MAX_DOCUMENT_COUNT = 100
    private_constant :MAX_DOCUMENT_COUNT

    # @param title [String] the RFC title
    # @param url [String] the text file URL for the RFC
    # @return [String] the RFC content
    def self.download_document(title:, url:)
      file_name = File.basename(url)
      file_path = File.join(library_cache_dir, file_name)

      content = Net::HTTP.get(URI(url))
      FileUtils.mkdir_p(library_cache_dir)
      File.write(file_path, content)
      add_to_catalog(title: title, url: url, path: file_path)

      content
    end

    # @param title [String] the RFC title
    # @param url [String] the text file URL for the RFC
    # @param path [String] the path to the local copy of the RFC
    # @return [String] the RFC content
    def self.load_document(title:, url:, path:)
      content = File.read(path)

      add_to_catalog(title: title, url: url, path: path)

      content
    end

    # These are referenced later on by the `rfc-reader library` command.
    #
    # @example
    #   [
    #     { title: "My RFC", url: "www.my-rfc.com/my-rfc.txt", path: ".cache/rfc-reader/library/my-rfc.txt" },
    #     ...
    #   ]
    # @return [Array<Hash<String, String>>] a list of RFC info hashes
    def self.catalog
      if File.exist?(library_cache_list_path)
        content = File.read(library_cache_list_path)
        JSON.parse(content, symbolize_names: true)
      else
        []
      end
    end

    # Adds the RFC to the beginning of the catalog and removes any existing entries.
    # These are referenced later on by the `rfc-reader library` command.
    #
    # @param title [String] the RFC title
    # @param url [String] the text file URL for the RFC
    # @param path [String] the path to the local copy of the RFC
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
        FileUtils.rm_f(path) if path.start_with?(library_cache_dir)
      end

      json = JSON.pretty_generate(list)
      FileUtils.mkdir_p(program_cache_dir)
      File.write(library_cache_list_path, json)
    end

    # Cache directories

    # @return [String]
    def self.xdg_cache_home
      ENV
        .fetch("XDG_CACHE_HOME") { File.join(Dir.home, ".cache") }
        .then { |path| File.expand_path(path) }
    end

    # @return [String]
    def self.program_cache_dir
      File.join(xdg_cache_home, "rfc_reader")
    end

    # @return [String]
    def self.library_cache_list_path
      File.join(program_cache_dir, "library_list.json")
    end

    # @return [String]
    def self.library_cache_dir
      File.join(program_cache_dir, "library")
    end
  end
end
