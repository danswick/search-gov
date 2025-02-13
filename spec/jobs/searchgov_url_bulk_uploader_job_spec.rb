# frozen_string_literal: true

describe SearchgovUrlBulkUploaderJob do
  it_behaves_like 'a searchgov job'

  describe '#perform' do
    let(:user) { users(:affiliate_admin) }
    let(:urls) do
      [
        'https://agency.gov/one-url',
        'https://agency.gov/another-url'
      ]
    end
    let(:perform) do
      subject.perform(user, 'some-file.txt', urls)
    end

    describe 'when there is a valid url list' do
      it 'uploads the first url' do
        perform
        expect(SearchgovUrl.find_by(url: urls[0])).not_to be(nil)
      end

      it 'uploads the second url' do
        perform
        expect(SearchgovUrl.find_by(url: urls[1])).not_to be(nil)
      end

      it 'sends the notification email' do
        expect { perform }.to change { ActionMailer::Base.deliveries.count }.by(1)
      end
    end

    context 'when reindexing URLs' do
      let(:perform) do
        subject.perform(user, 'some-file.txt', urls, reindex: true)
      end

      before { allow(BulkUrlUploader).to receive(:new).and_call_original }

      it 'runs the uploader with reindexing flagged on' do
        perform
        expect(BulkUrlUploader).to have_received(:new).
          with('some-file.txt', urls, reindex: true)
      end
    end
  end
end
