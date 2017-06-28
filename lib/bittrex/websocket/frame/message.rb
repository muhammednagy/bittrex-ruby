class Bittrex::WebSocket::Frame
  class Message
    MESSAGE_TYPES = [
      'updateSummaryState',
      'updateExchangeState'
    ].freeze

    attr_reader :hub, :type, :data

    def initialize(message_data)
      @hub      = message_data['H']
      @type     = message_data['M']
      @data     = message_data['A']
    end
  end
end
