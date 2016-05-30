# This file should not have any direct dependency on Rails environment
# please require all dependencies below:
require 'active_support/core_ext/hash/keys'

module Gitlab
  class Redis
    CACHE_NAMESPACE = 'cache:gitlab'
    SESSION_NAMESPACE = 'session:gitlab'
    SIDEKIQ_NAMESPACE = 'resque:gitlab'
    MAILROOM_NAMESPACE = 'mail_room:gitlab'
    DEFAULT_REDIS_URL = 'redis://localhost:6379'

    # To be thread-safe we must be careful when writing the class instance
    # variables @url and @pool. Because @pool depends on @url we need two
    # mutexes to prevent deadlock.
    PARAMS_MUTEX = Mutex.new
    POOL_MUTEX = Mutex.new
    private_constant :PARAMS_MUTEX, :POOL_MUTEX

    class << self
      def params
        @params || PARAMS_MUTEX.synchronize { @params = new.params }
      end

      # @deprecated Use .params instead to get sentinel support
      def url
        raw_config_hash[:url]
      end

      def with
        if @pool.nil?
          POOL_MUTEX.synchronize do
            @pool = ConnectionPool.new { ::Redis.new(params) }
          end
        end
        @pool.with { |redis| yield redis }
      end
    end

    def initialize(rails_env=nil)
      @rails_env = rails_env || Rails.env
    end

    def params
      redis_store_options
    end

    private

    def redis_store_options
      config = raw_config_hash

      redis_uri = URI.parse(config[:url])
      if redis_uri.scheme == 'unix'
        # Redis::Store does not handle Unix sockets well, so let's do it for them
        config[:path] = redis_uri.path
        config.delete(:url)
      else
        redis_hash = ::Redis::Store::Factory.extract_host_options_from_uri(redis_uri)
        config.merge!(redis_hash)
      end

      config
    end

    def raw_config_hash
      config_data = fetch_config

      if config_data
        config_data.is_a?(String) ? { url: config_data } : config_data.deep_symbolize_keys
      else
        { url: DEFAULT_REDIS_URL }
      end
    end

    def fetch_config
      File.exists?(config_file) ? YAML.load_file(config_file)[@rails_env] : false
    end

    def config_file
      File.expand_path('../../../config/resque.yml', __FILE__)
    end
  end
end
