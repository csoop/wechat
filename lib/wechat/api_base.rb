require 'cgi'

module Wechat
  class ApiBase
    attr_reader :access_token, :client

    MP_BASE = 'https://mp.weixin.qq.com/cgi-bin/'

    def callbackip
      get 'getcallbackip'
    end

    def qrcode(ticket)
      client.get 'showqrcode', ticket: CGI.escape(ticket), base: MP_BASE, as: :file
    end

    protected

    def get(path, headers = {})
      with_access_token(headers[:params]) do |params|
        client.get path, headers.merge(params: params)
      end
    end

    def post(path, payload, headers = {})
      with_access_token(headers[:params]) do |params|
        client.post path, payload, headers.merge(params: params)
      end
    end

    def with_access_token(params = {}, tries = 2)
      params ||= {}
      yield(params.merge(access_token: access_token.token))
    rescue AccessTokenExpiredError
      access_token.refresh
      retry unless (tries -= 1).zero?
    end
  end
end
