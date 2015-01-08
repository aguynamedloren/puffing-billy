require 'billy/handlers/handler'
require 'addressable/uri'

module Billy
  class StubHandler
    include Handler

    def handle_request(method, url, headers, body)
      if handles_request?(method, url, headers, body)
        if (stub = find_stub(method, url))
          query_string = Addressable::URI.parse(url).query || ""
          params = CGI.parse(query_string)
          stub.call(params, headers, body).tap do |response|
            Billy.log(:info, "puffing-billy: STUB #{method} for '#{url}'")
            return { status: response[0], headers: response[1], content: response[2] }
          end
        end
      end

      nil
    end

    def handles_request?(method, url, headers, body)
      !find_stub(method, url).nil?
    end

    def reset
      self.stubs = []
    end

    def stub(url, options = {})
      new_stub = ProxyRequestStub.new(url, options)
      stubs.unshift new_stub
      new_stub
    end

    private

    attr_writer :stubs

    def stubs
      @stubs ||= []
    end

    def find_stub(method, url)
      puts ">>> puffing-billy:"
      puts ">>> find_stub"
      puts ">>> method: #{method}"
      puts ">>> url: #{url}"
      puts ">>> stubs: "
      puts stubs
      puts "<<<"
      stubs.find { |stub| stub.matches?(method, url) }
    end
  end
end
