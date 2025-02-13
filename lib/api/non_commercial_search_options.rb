# frozen_string_literal: true

class Api::NonCommercialSearchOptions < Api::SearchOptions

  attr_accessor :audience,
                :content_type,
                :mime_type,
                :searchgov_custom1,
                :searchgov_custom2,
                :searchgov_custom3,
                :sort_by,
                :tags

  # SRCH-3615: Disabling cop temporarily as facets work is ongoing and will continue to involve
  # modifications to this method.
  # rubocop:disable Metrics/AbcSize
  def initialize(params = {})
    super
    self.audience = params[:audience]
    self.content_type = params[:content_type]
    self.mime_type = params[:mime_type]
    self.searchgov_custom1 = params[:searchgov_custom1]
    self.searchgov_custom2 = params[:searchgov_custom2]
    self.searchgov_custom3 = params[:searchgov_custom3]
    self.sort_by = params[:sort_by]
    self.tags = params[:tags]
  end
  # rubocop:enable Metrics/AbcSize

  def attributes
    super.merge({ audience: audience,
                  content_type: content_type,
                  mime_type: mime_type,
                  searchgov_custom1: searchgov_custom1,
                  searchgov_custom2: searchgov_custom2,
                  searchgov_custom3: searchgov_custom3,
                  sort_by: sort_by,
                  tags: tags })
  end
end
