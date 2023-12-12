# frozen_string_literal: true

RSpec.describe PageDownloader do
  let(:url) { 'https://www.google.com' }
  let(:downloader_class) { described_class::Downloader }

  it 'has a version number' do
    expect(PageDownloader::VERSION).not_to be_nil
  end

  context 'when testing the Downloader Class without metadata flag' do
    describe '#downalod_page' do
      it 'creates the page requested' do
        faraday_mock = stub_request(:any, url).to_return(body: '<html></html>', status: 200)
        downloader = downloader_class.new(url)

        expect(File).to receive(:write).once

        downloader.download_page

        expect(faraday_mock).to have_been_requested
      end
    end
  end

  context 'when testing the Downloader Class WITH metadata flag' do
    let(:nokogiri_doc) { instance_double(Nokogiri::HTML::Document) }
    let(:downloader) { downloader_class.new(url, metadata_flag: true) }
    let(:time_double) { instance_double(Time) }

    describe '#downalod_page' do
      it 'creates the page requested and returns the metadata hash' do
        allow(File).to receive(:exist?).with('www.google.com.html').and_return(true)
        allow(File).to receive(:mtime).with('www.google.com.html').and_return(time_double)
        allow(time_double).to receive_message_chain(:utc, :strftime).and_return('Tue Dec 12 2023 03:15 UTC')

        faraday_mock = stub_request(:any, url).to_return(body: '<html></html>', status: 200)
        expected_metadata = { site: 'https://www.google.com', num_links: 0, images: 0,
                              last_fetch: 'Tue Dec 12 2023 03:15 UTC' }

        expect(File).to receive(:write).once

        metadata = downloader.download_page

        expect(faraday_mock).to have_been_requested
        expect(metadata).to eq(expected_metadata)
      end
    end

    describe '#print_metadata' do
      it 'calls puts to print the metadata info' do
        downloader = downloader_class.new(url)

        expect($stdout).to receive(:puts).at_least(6)

        downloader.print_metadata
      end
    end
  end
end
