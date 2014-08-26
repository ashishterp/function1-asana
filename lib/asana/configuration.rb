module Asana
  # Holds the configuration options for the client and connection
  class Configuration
    # @return [String] The basic auth token.
    attr_accessor :api_key

    # @return [String] The API url. Must be https unless {#allow_http} is set.
    attr_accessor :url

    # @return [Boolean] Whether to attempt to retry when rate-limited (http status: 429).
    attr_accessor :retry

    # @return [Logger] Logger to use when logging requests.
    attr_accessor :logger

    # @return [Hash] Client configurations (eg ssh config) to pass to Faraday
    attr_accessor :client_options

    # @return [Symbol] Faraday adapter
    attr_accessor :adapter

    # @return [Boolean] Whether to allow non-HTTPS connections for development purposes.
    attr_accessor :allow_http

    # @return [String] OAuth2 access_token
    attr_accessor :access_token

    attr_accessor :url_based_access_token

    def initialize
      @client_options = {}
    end

    # Sets accept and user_agent headers, and url.
    #
    # @return [Hash] Faraday-formatted hash of options.
    def options
      {
        :headers => {
          :accept => 'application/json',
          :accept_encoding => 'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
          :user_agent => "Asana API #{Asana::VERSION}"
        },
        :url => @url
      }.merge(client_options)
    end
  end
end