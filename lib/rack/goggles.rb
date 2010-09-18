require "sinatra/base"

module Rack
  class Goggles < Sinatra::Base

    # Duh.
    VERSION = "1.0.0"

    set :static, false
    set :public, ::File.expand_path("../goggles/public", __FILE__)
    set :views,  ::File.expand_path("../goggles/views", __FILE__)

    def initialize app, prefix
      @prefix = prefix
      super app
    end

    get "/__goggles__/:file" do |file|
      send_file ::File.join(settings.public, file)
    end

    get "*" do |path|
      return forward unless path[0, @prefix.length] == @prefix

      env["PATH_INFO"]   = env["PATH_INFO"][@prefix.length..-1]
      env["REQUEST_URI"] = env["REQUEST_URI"][@prefix.length..-1]
      result             = @app.call env

      return result unless %r|application/json| =~ result[1]["Content-Type"]

      @json   = result.last.first
      @json   = "null" if @json.empty?
      @status = result.first
      @uri    = env["REQUEST_URI"]

      erb :goggles
    end
  end
end
