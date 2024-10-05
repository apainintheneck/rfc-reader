# frozen_string_literal: true

require "net/http"
require "nokogiri"

module RfcReader
  module Recent
    RECENT_RFCS_RSS_URI = URI("https://www.rfc-editor.org/rfcrss.xml").freeze
    private_constant :RECENT_RFCS_RSS_URI

    # @return [Hash<String, String>] from RFC title to text file url
    def self.list
      xml = fetch
      parse(xml)
    end

    # @return [String] the raw XML from the recent RFCs RSS feed
    def self.fetch
      ErrorContext.wrap("Fetching the recent RFCs list") do
        Net::HTTP.get(RECENT_RFCS_RSS_URI)
      end
    end

    # Example: XML fragment we're trying to parse title and link data from.
    #
    # ```xml
    # <item>
    #   <title>
    #   RFC 9624: EVPN Broadcast, Unknown Unicast, or Multicast (BUM) Using Bit Index Explicit Replication (BIER)
    #   </title>
    #   <link>https://www.rfc-editor.org/info/rfc9624</link>
    #   <description>
    #   This document specifies protocols and procedures for forwarding Broadcast, Unknown Unicast, or Multicast (BUM) traffic of Ethernet VPNs (EVPNs) using Bit Index Explicit Replication (BIER).
    #   </description>
    # </item>
    # ```
    #
    # @param xml [String] the XML of the recent RFCs RSS endpoint
    # @return [Hash<String, String>] from RFC title to text file url
    def self.parse(xml)
      ErrorContext.wrap("Parsing the recent RFCs list") do
        Nokogiri::XML(xml).xpath("//item").to_h do |item|
          item_hash = item.elements.to_h do |elem|
            [elem.name, elem.text.strip]
          end

          # The link is to the webpage and not the plaintext document so we must convert it.
          file_name = File.basename(item_hash.fetch("link"))

          [
            item_hash.fetch("title"),
            "https://www.rfc-editor.org/rfc/#{file_name}.txt",
          ]
        end
      end
    end
  end
end
