# frozen_string_literal: true

require 'faraday'
require 'nokogiri'
require 'ruby-progressbar'
require_relative 'page_downloader/version'

module PageDownloader
  class Downloader
    attr_reader :url, :metadata

    def initialize(url, metadata_flag: false)
      @url = url
      @metadata_flag = metadata_flag
      @metadata = {}
      @bar_options = { format: '%a ~%e | Processed: %c from %C | %P% Completed' }
      @pb = nil
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

    def get_with_faraday(url)
      Faraday.get(url)
    end

    def fetch_page
      response = get_with_faraday(url)
      raise StandardError, "Error downloading the page #{url}, HTTP Status Code: #{response.status}" if response.status != 200

      response.body
    end

    def save_page(filename, nokogiri_html)
      final_filename = "#{filename}.html"
      updated_html = save_assets(filename, nokogiri_html)
      html_to_save = updated_html.to_html

      File.write(final_filename, html_to_save)

      final_filename
    end

    def save_assets(filename, nokogiri_html)
      normalized_filename = filename.tr('.', '_')
      destination_folder = File.join('pages_assets', "#{normalized_filename}_assets")
      images_in_html = nokogiri_html.css('img')
      total_imgs = images_in_html.size

      FileUtils.mkdir_p(destination_folder)

      setup_progress_bar(total_imgs)

      update_images_path(destination_folder, images_in_html)

      nokogiri_html
    end

    def download_file(url, path)
      response = get_with_faraday(url)
      raise StandardError, "Error while downloading the file: #{url}, Status: #{response.status}" unless response.status == 200

      File.binwrite(path, response.body)
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

    def setup_progress_bar(total_imgs)
      @pb = ProgressBar.create(**@bar_options,
                               starting_at: 0,
                               length: 50,
                               total: total_imgs)
    end

    def update_images_path(destination_folder, images_in_html)
      images_in_html.each do |img|
        next if img['src'].nil? || img['src'].empty?

        image_url = URI.join(url, img['src']).to_s
        img_path = URI.parse(img['src']).path
        local_image_name = File.basename(img_path)
        local_image_path = File.join(destination_folder, local_image_name)

        download_file(image_url, local_image_path)
        img['src'] = local_image_path

        @pb.increment
      end
    end
  end
end
