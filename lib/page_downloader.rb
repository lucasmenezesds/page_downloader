# frozen_string_literal: true

require 'faraday'
require 'nokogiri'
require_relative 'page_downloader/version'

module PageDownloader
  class Downloader
    attr_reader :url

    def initialize(url)
      @url = url
    end

    def download_page
      body = fetch_page
      parsed_html = parse_html(body)

      filename = @url.to_s.split('://').last
      save_page(filename, parsed_html)
    end

    private

    def fetch_page
      response = Faraday.get(url)
      raise StandardError, "Error downloading the page #{url}, HTTP Status Code: #{response.status}" if response.status != 200

      response.body
    end

    def save_page(filename, nokogiri_html)
      final_filename = "#{filename}.html"
      html = nokogiri_html.to_html

      File.write(final_filename, html)
    end

    def parse_html(html_body)
      Nokogiri::HTML(html_body)
    end
  end
end
