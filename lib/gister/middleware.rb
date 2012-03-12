require 'open-uri'

require_relative 'fetcher'

module Gister
  class Middleware
    def initialize(app, fetcher=Fetcher.new)
      @app = app
      @fetcher = fetcher
    end

    def call(env)
      request = Rack::Request.new env
      if request.path =~ /^\/gist\/[0-9]+.json/
        respond_to_failures do
          [200, {'Content-Type' => 'application/javascript'}, [get_body_content(request)]]
        end
      else
        @app.call(env)
      end
    end

    private

    def respond_to_failures
      yield
    rescue Fetcher::ClientError
      [404, {}, [""]]
    end

    def get_body_content(request)
      path = request.path.gsub("/gist/", '')
      path = "https://gist.github.com/#{path}?file=#{request.params["file"]}"

      response = fetch_by_path path
      wrap_in_jsonp(request.params["callback"], response)
    end

    def wrap_in_jsonp(callback, response)
      "#{callback}(#{response})"
    end

    def fetch_by_path(path)
      @fetcher.fetch path
    end

  end
end
