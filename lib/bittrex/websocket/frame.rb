class Bittrex::WebSocket
  class Frame
    attr_reader :hub,
                :marker, :messages,
                :result, :index

    RESULT_KEY   = 'R'.freeze
    MARKER_KEY   = 'C'.freeze
    DATA_KEY     = 'A'.freeze
    MESSAGES_KEY = 'M'.freeze
    INDEX_KEY    = 'I'.freeze

    def initialize(frame_data)
      @result   = frame_data[RESULT_KEY]
      @marker   = frame_data[MARKER_KEY]
      @data     = frame_data[DATA_KEY]
      @index    = frame_data[INDEX_KEY]
      if frame_data[MESSAGES_KEY].is_a? Array
        @messages = frame_data[MESSAGES_KEY].map do |message_data|
          Message.new(message_data)
        end
      end
      # 'R' - Response. Ignored now.
    end
  end
end
