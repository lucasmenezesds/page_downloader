# frozen_string_literal: true

require 'faraday'
require 'nokogiri'
require_relative 'page_downloader/version'

module PageDownloader
  class Downloader
    attr_reader :url, :metadata

    def initialize(url, metadata_flag: false)
      @url = url
      @metadata_flag = metadata_flag
      @metadata = {}
    end

    def download_page
      body = fetch_page
      parsed_html = parse_html(body)

      filename = @url.to_s.split('://').last

      collect_metadata(parsed_html) if @metadata_flag

      final_filename = save_page(filename, parsed_html)

      update_metadata(final_filename) if @metadata_flag
    end

    def print_metadata
      puts '== Website Metadata =='
      puts "  site: #{@metadata[:site]}"
      puts "  num_links: #{@metadata[:num_links]}"
      puts "  images: #{@metadata[:images]}"
      puts "  last_fetch: #{@metadata[:last_fetch]}"
      puts '===='
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

      final_filename
    end

    def parse_html(html_body)
      Nokogiri::HTML(html_body)
    end

    def collect_metadata(nokogiri_doc)
      @metadata[:site] = @url
      @metadata[:num_links] = nokogiri_doc.css('a').count || 0
      @metadata[:images] = nokogiri_doc.css('img').count || 0
    end

    def update_metadata(final_filename)
      return unless File.exist?(final_filename)

      last_modified_at = File.mtime(final_filename)
      @metadata[:last_fetch] = last_modified_at.utc.strftime('%a %b %d %Y %H:%M UTC')

      @metadata
    end
  end
end
