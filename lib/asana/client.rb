require 'faraday'
require 'asana/configuration'
require 'asana/users'
require 'asana/tasks'
require 'asana/middleware/response/parse_json'

module Asana
  class Client
    include Asana::Client::Users
    include Asana::Client::Tasks


    # @return [Configuration] Config instance
    attr_reader :config

    # @return [Array] Custom response callbacks
    attr_reader :callbacks

    # Returns the current user (aka me)
    # @return [Asana::User] Current user or nil
    def current_user(reload = false)
      return @current_user if @current_user && !reload
      @current_user = user('me')
    end

    def initialize
      raise ArgumentError, "block not given" unless block_given?
      @config = Asana::Configuration.new
      yield config
      config.retry = !!config.retry # nil -> false
      set_default_logger
    end

    # Creates a connection if there is none, otherwise returns the existing connection.
    #
    # @return [Faraday::Connection] Faraday connection for the client
    def connection
      @connection ||= build_connection
      return @connection
    end

    # Pushes a callback onto the stack. Callbacks are executed on responses, last in the Faraday middleware stack.
    # @param [Proc] block The block to execute. Takes one parameter, env.
    def insert_callback(&block)
      @callbacks << block
    end

    protected

    # Called by {#connection} to build a connection. Can be overwritten in a
    # subclass to add additional middleware and make other configuration
    # changes.
    #
    # Uses middleware according to configuration options.
    #
    # Request logger if logger is not nil
    #
    # Retry middleware if retry is true
    def build_connection
      conn = Faraday.new(:url => 'https://app.asana.com/') do |faraday|
        faraday.request  :url_encoded             # form-encode POST params
        faraday.response :logger                  # log requests to STDOUT
        faraday.adapter  Faraday.default_adapter  # make requests with Net::HTTP
        faraday.basic_auth @config.api_key, '' if @config.api_key
        faraday.headers['Content-Type'] = 'application/json'
        faraday.use Asana::Middleware::Response::ParseJson
      end
    end

    private

    def set_default_logger
      if config.logger.nil? || config.logger == true
        require 'logger'
        config.logger = Logger.new($stderr)
        config.logger.level = Logger::WARN
      end
    end

  end
end