# This file is used by Rack-based servers to start the application.

require 'faye'
require_relative 'config/environment'
require_relative 'lib/websocket_server/websocket_creator'

server = Faye::RackAdapter.new(:mount => '/faye', :timeout => 25)
websocketserver = WebsocketCreator.new
server.add_extension(websocketserver)


server.bind(:handshake) do |client_id|
puts "Faye.ru Bayeux:: Client #{client_id} connected"
end

server.bind(:subscribe) do |client_id, channel|
puts "Faye.ru Bayeux:: Client #{client_id} subscribed to #{channel}"
end

server.bind(:unsubscribe) do |client_id, channel|
puts "Faye.ru Bayeux:: Client #{client_id} unsubscribed from #{channel}"
end

server.bind(:disconnect) do |client_id|
puts "Bayeux:: Client #{client_id} disconnected"
end

run server
