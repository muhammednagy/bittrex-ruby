class Bittrex::WebSocket
  class Frame
    attr_reader :hub, :marker, :messages

    def initialize(frame_data)
      @marker   = frame_data['C']
      @data     = frame_data['A']
      @messages = frame_data['M'].map do |message_data|
        Message.new(message_data)
      end
      # 'R' - Response. Ignored now.
    end
  end
end
