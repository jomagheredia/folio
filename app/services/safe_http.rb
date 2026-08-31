# frozen_string_literal: true

require "ipaddr"
require "net/http"
require "resolv"
require "uri"

# Fetches a remote URL after rejecting private/loopback destinations (SSRF).
class SafeHttp
  class Error < StandardError; end

  Result = Struct.new(:body, :content_type, :uri, keyword_init: true)
  Fetch = Struct.new(:code, :location, :content_type, :body, :success, :redirect, keyword_init: true)

  USER_AGENT = "Folio/1.0"
  MAX_REDIRECTS = 5
  BLOCKED_HOSTS = %w[localhost localhost.localdomain metadata.google.internal].freeze

  PRIVATE_RANGES = [
    IPAddr.new("0.0.0.0/8"),
    IPAddr.new("10.0.0.0/8"),
    IPAddr.new("127.0.0.0/8"),
    IPAddr.new("169.254.0.0/16"),
    IPAddr.new("172.16.0.0/12"),
    IPAddr.new("192.168.0.0/16"),
    IPAddr.new("::1/128"),
    IPAddr.new("fc00::/7"),
    IPAddr.new("fe80::/10")
  ].freeze

  def self.get(url, max_bytes: 1.megabyte, timeout: 8)
    new(url, max_bytes:, timeout:).get
  end

  def initialize(url, max_bytes:, timeout:)
    @url = url
    @max_bytes = max_bytes
    @timeout = timeout
  end

  def get
    uri = parse_uri(@url)
    redirects = 0

    loop do
      validate!(uri)
      fetch = request(uri)

      if fetch.redirect
        redirects += 1
        raise Error, "too many redirects" if redirects > MAX_REDIRECTS
        raise Error, "redirect missing location" if fetch.location.blank?

        uri = uri.merge(fetch.location)
        next
      end

      raise Error, "request failed (#{fetch.code})" unless fetch.success

      return Result.new(body: fetch.body, content_type: fetch.content_type, uri:)
    end
  end

  private
    def parse_uri(value)
      uri = URI.parse(value.to_s.strip)
      raise Error, "must be http or https" unless uri.is_a?(URI::HTTP) && uri.host.present?

      uri
    rescue URI::InvalidURIError
      raise Error, "invalid URL"
    end

    def validate!(uri)
      host = uri.host.to_s.downcase
      raise Error, "blocked host" if BLOCKED_HOSTS.include?(host)
      raise Error, "blocked host" if host.end_with?(".localhost", ".local")
      raise Error, "blocked destination" if private_or_local?(host)
    end

    def private_or_local?(host)
      resolve(host).any? { |address| private_ip?(address) }
    end

    def resolve(host)
      if ip?(host)
        [ host ]
      else
        Resolv.getaddresses(host).presence || raise(Error, "could not resolve host")
      end
    rescue Resolv::ResolvError
      raise Error, "could not resolve host"
    end

    def ip?(host)
      IPAddr.new(host)
      true
    rescue IPAddr::InvalidAddressError
      false
    end

    def private_ip?(address)
      ip = IPAddr.new(address)
      ip = ip.native if ip.ipv4_mapped?
      PRIVATE_RANGES.any? { |range| range.include?(ip) }
    rescue IPAddr::InvalidAddressError
      true
    end

    def request(uri)
      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = uri.scheme == "https"
      http.open_timeout = @timeout
      http.read_timeout = @timeout
      http.write_timeout = @timeout if http.respond_to?(:write_timeout=)

      request = Net::HTTP::Get.new(uri)
      request["User-Agent"] = USER_AGENT

      http.request(request) do |response|
        body = +""
        unless response.is_a?(Net::HTTPRedirection)
          response.read_body do |chunk|
            body << chunk
            raise Error, "response too large" if body.bytesize > @max_bytes
          end
        end

        return Fetch.new(
          code: response.code,
          location: response["location"],
          content_type: response["content-type"].to_s,
          body:,
          success: response.is_a?(Net::HTTPSuccess),
          redirect: response.is_a?(Net::HTTPRedirection)
        )
      end
    rescue Net::OpenTimeout, Net::ReadTimeout, Errno::ECONNREFUSED, Errno::ECONNRESET, Errno::EHOSTUNREACH, SocketError => e
      raise Error, e.message
    end
end
