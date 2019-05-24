require_relative '../../config/environment.rb'
require "#{Rails.root}/lib/websocket_server/websocket_server"

class WebsocketServerManager

  def initialize
    @has_start = false
    # Faye.ensure_reactor_running!
    # client = Faye::Client.new('http://localhost:3000/faye')
    # client.publish("/meta/disconnect",nil)
    # client.disconnect
  end

  def run
    @has_start = true
    @websocketserver = WebsocketServer.new(15, 10)
    @websocketserver.run
  end

  def has_start?
    @has_start
  end

end
