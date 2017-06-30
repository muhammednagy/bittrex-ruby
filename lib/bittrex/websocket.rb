require 'faraday'
require 'json'
require 'faye/websocket'
require_relative './websocket/frame'
require_relative './websocket/frame/message'

module Bittrex
  class WebSocket
    WSS_HOST = 'wss://socket.bittrex.com/signalr/connect'.freeze
    SIGNALR_OPTIONS_URL = 'https://socket.bittrex.com/signalr/negotiate'.freeze
    SIGNALR_OPTIONS_QUERY_PARAMS =
      { clientProtol: 1.5, connectionData: [{'name' => 'corehub'}] }.freeze
    DEFAULT_SIGNALR_PARAMS = {
      'transport' => 'webSockets',
      'clientProtol' => 1.5,
      'connectionData' => "[{\"name\":\"corehub\"}]",
      'tid' => 10
    }.freeze

    attr_reader :key, :secret,
                :signalr_options, :frames

    def initialize(callback_instance, logger = nil)
      @callbacks_instance = callback_instance
      @logger             = logger
      @frames             = []
      get_signalr_options
    end

    def get_signalr_options
      response = Faraday.new(:url => SIGNALR_OPTIONS_URL) do |faraday|
        faraday.request :url_encoded
        faraday.adapter Faraday.default_adapter
      end.get do |req|
        req.params.merge!(SIGNALR_OPTIONS_QUERY_PARAMS)
        req.url(SIGNALR_OPTIONS_URL)
      end
      @signalr_options = JSON.parse(response.body)
    end

    def run_websocket_connection
      link = WSS_HOST + "?" + Faraday::FlatParamsEncoder.encode(
        DEFAULT_SIGNALR_PARAMS.merge({
          'connectionToken' => @signalr_options['ConnectionToken']
        })
      )
      to_log("connect to websocket by link: #{link}")
      @ws_client = Faye::WebSocket::Client.new(link)
    end

    def on_open(_event)
      to_log('Connection opened successfully')
      if @callbacks_instance.respond_to? :on_open
        @callbacks_instance.on_open(_event)
      end
      # @ws_client.send({
      #   'H' => 'corehub', 'M' => 'SubscribeToUserDeltas'
      # })
      # @ws_client.send({
      #   'H' => 'corehub', 'M' => 'SubscribeToExchangeDeltas'
      # })
    end

    def on_message(event)
      data = JSON.parse(event.data)
      return nil if data == {}
      frame = Frame.new(data)
      @frames << frame
      to_log("WebSocket frame: #{event.data.to_s[0...300]}")
      if @callbacks_instance.respond_to? :on_message
        @callbacks_instance.on_message(frame)
      end
    end

    def on_close(event)
      to_log("Connection closed!!! #{event.code}, #{event.reason}")
      if @callbacks_instance.respond_to? :on_close
        @callbacks_instance.on_close(event)
      end
    end

    def run_websocket_monitoring
      EM.run {
        run_websocket_connection

        @ws_client.on(:open)    { |event| on_open(event) }
        @ws_client.on(:message) { |event| on_message(event) }
        @ws_client.on(:close)   { |event| on_close(event) }
      }
    end

    def to_log(text)
      return unless @logger
      @logger.info(text)
    end
  end
end
