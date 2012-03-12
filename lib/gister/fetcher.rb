require 'faraday'

module Gister
  class Fetcher
    class MemoryStore
      def initialize; @store = Hash.new; end
      def set(k,v); @store[k]=v; end
      def get(k); @store[k]; end
    end

    ClientError = Class.new(StandardError)
    GistNotFound = Class.new(ClientError)

    attr_writer :store

    def initialize(store = MemoryStore.new)
      @store = store
    end

    def fetch(key)
      if result = get(key)
        result
      else
        result = fetch_result(key)
        set key, result
        result
      end
    end
    
    def get(k); @store.get(cache_bust(k)); end
    def set(k, v); @store.set(cache_bust(k), v); end

    private

    def cache_bust(key)
      cache_buster + key
    end

    def cache_buster
      ENV['CACHE_BUSTER'].to_s
    end

    def fetch_result(key)
      path, params = parse_uri(key)

      wrap_exceptions do
        response = connection.get(path) do |req|
          req.params = params
        end
        response.body
      end
    end

    def wrap_exceptions
      yield
    rescue Faraday::Error::ResourceNotFound
      raise GistNotFound.new($!)
    rescue Faraday::Error::ClientError
      raise ClientError.new($1)
    end

    def connection
      @connection ||= Faraday.new(url: "https://gist.github.com") do |builder|
        builder.use Faraday::Request::JSON
        builder.use Faraday::Response::RaiseError
        builder.use Faraday::Adapter::NetHttp
      end
    end

    def parse_uri(uri)
      uri = URI.parse(uri)
      [uri.path, parse_params(uri.query)]
    end

    def parse_params(query_string)
      query_string.split("&").inject(Hash.new) do |hash, kv| 
        key, value = kv.split("=")
        hash[key] = value
        hash
      end
    end
  end
end
