class Bittrex::WebSocket::Frame
  class Message

    HUB_KEY  = 'H'.freeze
    TYPE_KEY = 'M'.freeze
    DATA_KEY = 'A'.freeze

    UPDATE_MARKETS_SUMMARY_TYPE = 'updateSummaryState'.freeze
    UPDATE_EXCHANGE_STATE_TYPE  = 'updateExchangeState'.freeze

    attr_reader :hub, :type, :data

    def initialize(message_data)
      @hub      = message_data[HUB_KEY]
      @type     = message_data[TYPE_KEY]
      @data     = message_data[DATA_KEY]
    end
  end
end
