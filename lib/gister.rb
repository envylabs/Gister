require 'gister/railtie' if defined?(Rails)

module Gister
  def self.fetcher
    @fetcher ||= Fetcher.new
  end
end
