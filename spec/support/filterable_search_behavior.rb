# frozen_string_literal: true

shared_examples 'an initialized filterable search' do
  context 'when since_date and until_date are valid' do
    subject(:test_search) do
      described_class.new filterable_search_options.
        merge(since_date: '8/20/2012',
              until_date: '11/30/2014')
    end

    let(:expected_since) { DateTime.parse('2012-08-20T00:00:00Z') }
    let(:expected_until) { DateTime.parse('2014-11-30T23:59:59.999999999Z') }

    its(:since) { is_expected.to eq(expected_since) }
    its(:until) { is_expected.to eq(expected_until) }
  end

  context 'when since_date is invalid and until_date is valid' do
    subject(:test_search) do
      described_class.new filterable_search_options.
        merge(since_date: '20/20/2012',
              until_date: '11/30/2014')
    end

    let(:expected_since) { DateTime.parse('2013-11-30T00:00:00Z') }
    let(:expected_until) { DateTime.parse('2014-11-30T23:59:59.999999999Z') }

    its(:since) { is_expected.to eq(expected_since) }
    its(:until) { is_expected.to eq(expected_until) }
  end

  context 'when since_date is invalid and until_date is blank' do
    subject(:test_search) do
      described_class.new filterable_search_options.
        merge(since_date: '20/20/2012',
              until_date: '')
    end

    let(:expected_since) { DateTime.current.prev_year.beginning_of_day }

    its(:since) { is_expected.to eq(expected_since) }
    its(:until) { is_expected.to be_nil }
  end

  context 'when until_date is invalid' do
    subject(:test_search) do
      described_class.new filterable_search_options.
        merge(since_date: '8/20/2012',
              until_date: '20/30/2014')
    end

    let(:expected_since) { DateTime.parse('2012-08-20T00:00:00Z') }
    let(:expected_until) { DateTime.current.end_of_day }

    its(:since) { is_expected.to eq(expected_since) }
    its(:until) { is_expected.to eq(expected_until) }
  end

  context 'when since_date is > until_date' do
    subject(:test_search) do
      described_class.new filterable_search_options.
        merge(since_date: '12/25/2014',
              until_date: '10/18/2012')
    end

    let(:expected_since) { DateTime.parse('2012-10-18T00:00:00Z') }
    let(:expected_until) { DateTime.parse('2014-12-25T23:59:59.999999999Z') }

    its(:since) { is_expected.to eq(expected_since) }
    its(:until) { is_expected.to eq(expected_until) }
  end

  context 'when locale is set to :es' do
    before(:all) { I18n.locale = :es }

    after(:all) { I18n.locale = I18n.default_locale }

    context 'when the since_date and until_date params are valid' do
      subject(:test_search) do
        described_class.new filterable_search_options.
          merge(since_date: '25/12/2014',
                until_date: '18/10/2012')
      end

      let(:expected_since) { DateTime.parse('2012-10-18T00:00:00Z') }
      let(:expected_until) { DateTime.parse('2014-12-25T23:59:59.999999999Z') }

      its(:since) { is_expected.to eq(expected_since) }
      its(:until) { is_expected.to eq(expected_until) }
    end
  end

  context 'when tbs is valid' do
    def eval_str_to_value(str)
      attribute_chain = str.split('.')
      initial = eval attribute_chain.shift
      attribute_chain.inject(initial) do |value, attr|
        value.send(attr)
      end
    end

    subject(:test_search) do
      described_class.new filterable_search_options.
        merge(tbs: RSpec.current_example.metadata[:tbs])
    end

    context 'when tbs is last hour', tbs: 'h' do
      let(:expected_since_to_i) { DateTime.current.advance(hours: -1).to_i }

      its(:'since.to_i') { is_expected.to be_within(3).of(expected_since_to_i) }
    end

    time_filter_options = {
      day: 'DateTime.current.advance(days: -1).beginning_of_day',
      week: 'DateTime.current.advance(weeks: -1).beginning_of_day',
      month: 'DateTime.current.advance(months: -1).beginning_of_day',
      year: 'DateTime.current.advance(years: -1).beginning_of_day'
    }

    time_filter_options.each do |tbs_description, expected_since_str|
      tbs = tbs_description.to_s[0]
      context "when tbs is last #{tbs_description}", tbs: tbs do
        its(:since) { is_expected.to eq(eval expected_since_str) }
      end
    end
  end

  context 'when tbs is not valid' do
    subject(:test_search) do
      described_class.new filterable_search_options.
        merge(tbs: 'GGG')
    end

    its(:since) { is_expected.to be_nil }
  end

  context 'when facet filters are present' do
    subject(:test_search) do
      described_class.new filterable_search_options.
        merge(audience: 'everyone',
              content_type: 'article',
              mime_type: 'application/pdf',
              searchgov_custom1: 'custom1',
              searchgov_custom2: 'custom2',
              searchgov_custom3: 'custom3')
    end

    its(:audience) { is_expected.to eq('everyone') }
    its(:content_type) { is_expected.to eq('article') }
    its(:mime_type) { is_expected.to eq('application/pdf') }
    its(:searchgov_custom1) { is_expected.to eq('custom1') }
    its(:searchgov_custom2) { is_expected.to eq('custom2') }
    its(:searchgov_custom3) { is_expected.to eq('custom3') }
  end
end

shared_examples 'a runnable filterable search' do
  context 'when since_date or until_date are present' do
    subject(:test_search) do
      described_class.new filterable_search_options.
        merge(since_date: '8/20/2012',
              until_date: '11/30/2014')
    end

    it 'searches for results between since_date and start_date' do
      expect(ElasticBlended).to receive(:search_for).
        with(hash_including(since: DateTime.parse('2012-08-20T00:00:00Z'),
                            until: DateTime.parse('2014-11-30T23:59:59.999999999Z'))).
        and_return(double(ElasticBlendedResults,
                          results: [],
                          suggestion: nil,
                          total: 0))
      subject.run
    end
  end
end
