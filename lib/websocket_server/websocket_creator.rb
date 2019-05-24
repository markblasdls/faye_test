require_relative '../../config/environment.rb'
require "#{Rails.root}/lib/websocket_server/websocket_server_manager"
class WebsocketCreator
  def initialize
    @websocketservermanager = WebsocketServerManager.new
  end

  def incoming(message, callback)
    puts "WEBSOCKET #{message}"
    if !@websocketservermanager.has_start?
      @websocketservermanager.run
    end
    # Call the server back now we're done
    callback.call(message)
  end

  # def run
  #   if !@websocketservermanager.has_start?
  #     @websocketservermanager.run
  #   end
  # end

end
