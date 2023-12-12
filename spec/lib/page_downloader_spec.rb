# frozen_string_literal: true

# MockHtml = Struct.new(:body, :status)

RSpec.describe PageDownloader do
  it 'has a version number' do
    expect(PageDownloader::VERSION).not_to be_nil
  end

  context 'when testing the Downloader Class' do
    describe '#downalod_page' do
      let(:url) { 'https://www.google.com' }
      let(:downloader_class) { described_class::Downloader }

      it 'created the page requested' do
        faraday_mock = stub_request(:any, url).to_return(body: '<html></html>', status: 200)
        downloader = downloader_class.new(url)

        expect(File).to receive(:write).once

        downloader.download_page

        expect(faraday_mock).to have_been_requested
      end
    end
  end
end
