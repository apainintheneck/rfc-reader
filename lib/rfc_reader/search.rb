# frozen_string_literal: true

require "net/http"
require "nokogiri"

module RfcReader
  module Search
    RFC_SEARCH_URI = URI("https://www.rfc-editor.org/search/rfc_search_detail.php").freeze
    private_constant :RFC_SEARCH_URI

    # @param term [String]
    # @return [Hash<String, String>] from RFC title to text file url
    def self.search_by(term:)
      html = fetch_by(term: term)
      parse(html)
    end

    # @param term [String]
    # @return [String] the raw HTML of the search results for the given term
    def self.fetch_by(term:)
      Net::HTTP.post_form(RFC_SEARCH_URI, { combo_box: term }).body
    end

    # Example: HTML fragment we're trying to parse title and link info from.
    #
    # ```html
    # <div class="scrolltable">
    #   <table class='gridtable'>
    #       <tr>
    #           <th>
    #               <a href='rfc_search_detail.php?sortkey=Number&sorting=DESC&page=25&title=ftp&pubstatus[]=Any&pub_date_type=any'>Number</a>
    #           </th>
    #           <th>Files</th>
    #           <th>Title</th>
    #           <th>Authors</th>
    #           <th>
    #               <a href='rfc_search_detail.php?sortkey=Date&sorting=DESC&page=25&title=ftp&pubstatus[]=Any&pub_date_type=any'>Date</a>
    #           </th>
    #           <th>More Info</th>
    #           <th>Status</th>
    #       </tr>
    #       <tr>
    #           <td>
    #               <a href="https://www.rfc-editor.org/info/rfc114" target="_blank">RFC&nbsp;114</a>
    #           </td>
    #           <td>
    #               <a href="https://www.rfc-editor.org/rfc/rfc114.txt" target="_blank">ASCII</a>
    #               ,
    #               <a href="https://www.rfc-editor.org/pdfrfc/rfc114.txt.pdf" target="_blank">PDF</a>
    #               ,
    #               <a href="https://www.rfc-editor.org/rfc/rfc114.html" target="_blank">HTML</a>
    #           </td>
    #           <td class="title"> File Transfer Protocol </td>
    #           <td> A.K. Bhushan</td>
    #           <td>April 1971</td>
    #           <td>
    #               Updated by
    #               <a href="https://www.rfc-editor.org/info/rfc133" target="_blank">RFC&nbsp;133</a>
    #               ,
    #               <a href="https://www.rfc-editor.org/info/rfc141" target="_blank">RFC&nbsp;141</a>
    #               ,
    #               <a href="https://www.rfc-editor.org/info/rfc171" target="_blank">RFC&nbsp;171</a>
    #               ,
    #               <a href="https://www.rfc-editor.org/info/rfc172" target="_blank">RFC&nbsp;172</a>
    #           </td>
    #           <td>Unknown</td>
    #       </tr>
    # ...
    # ```
    #
    # @param html [String] the HTML of the search results
    # @return [Hash<String, String>] from RFC title to text file url
    def self.parse(html)
      # NOTE: The first element in the table is just some general search information. See example HTML above.
      Nokogiri::HTML(html).xpath("//div[@class='scrolltable']//table[@class='gridtable']//tr").drop(1).to_h do |tr_node|
        title = tr_node.xpath("td[@class='title']").text
        url = tr_node
          .xpath("//td//a")
          .find { |link_node| link_node.text == "ASCII" }
          .attribute("href")
          .text

        [title, url]
      end
    end
  end
end
