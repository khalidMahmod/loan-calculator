module Rack
  class File
    def initialize(root, headers = {}, default_mime = 'text/plain')
      @root = root.chomp('/')
      @headers = { 'Content-Type' => default_mime }.merge(headers)
    end
  end
end unless defined?(Rack::File)
