# frozen_string_literal: true

module CanonicalTagHelper
  # Parameters that identify distinct content. Anything else is dropped so that
  # param spam does not dilute the canonical URL across near-identical pages.
  CANONICAL_QUERY_PARAMETERS = %w[keywords page search taxon].freeze
  COLLECTION_ACTIONS = %w[index].freeze
  DEFAULT_PORTS = { 'http://' => 80, 'https://' => 443 }.freeze

  def canonical_tag(host)
    tag.link(href: canonical_url(host), rel: :canonical)
  end

  private

  def canonical_url(host)
    "#{request.protocol}#{host}#{canonical_port}#{canonical_path}#{canonical_query_string}"
  end

  def canonical_port
    return '' if request.port == DEFAULT_PORTS[request.protocol]

    ":#{request.port}"
  end

  def canonical_path
    path = request.path == '/' ? '' : request.path.sub(/\.\w{3,4}\z/, '')
    trailing_slash = COLLECTION_ACTIONS.include?(params[:action]) ? '/' : ''

    "#{path}#{trailing_slash}"
  end

  def canonical_query_string
    canonical_parameters = params.to_unsafe_h
                                 .slice(*CANONICAL_QUERY_PARAMETERS)
                                 .select { |_, value| value.present? }
    return '' if canonical_parameters.empty?

    "?#{canonical_parameters.to_query}"
  end
end
