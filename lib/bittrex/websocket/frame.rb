class Bittrex::WebSocket
  class Frame
    attr_reader :hub, :marker, :messages

    def initialize(frame_data)
      @marker   = frame_data['C']
      @data     = frame_data['A']
      if frame_data['M'].is_a? Array
        @messages = frame_data['M'].map do |message_data|
          Message.new(message_data)
        end
      end
      # 'R' - Response. Ignored now.
    end
  end
end
