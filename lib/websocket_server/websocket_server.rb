require_relative '../../config/environment.rb'

require 'eventmachine'
require 'faye'
require 'json'
require 'logger'

module JSON
  def self.is_json?(foo)
    begin
      return false unless foo.is_a?(String)
      JSON.parse(foo).all?
    rescue JSON::ParserError
      false
    end
  end
end

class WebsocketServer

  def initialize(timeout, second_timeout)

    @timeout = timeout
    @second_timeout = second_timeout

    @channel = "/websocket"
    @logger = Logger.new(STDOUT)
    @logger.level = Logger::DEBUG
    @current_ping_time = 1

  end

  def log msg
    @logger.info "[WebsocketServer SERVER] #{msg}"
  end

  def run

    EM.run {
      begin
        @logger.info "WebsocketServer:: Contacting Faye <3 1"
        @client = Faye::Client.new('http://localhost:3000/faye')

        # log "#{Rails.application.secrets.websocket_url} --- game url"
        # @client.add_extension(GameAuthExtension.new)
        @logger.info "WebsocketServer:: Contacting Faye <3"
        log "websocket_receiver_channel #{websocket_receiver_channel}"
        @client.subscribe(websocket_receiver_channel) do |m|
          websocket_receiver_message = m
          log "websocket_receiver_message #{websocket_receiver_message}"
          if JSON.is_json?(m)
            websocket_receiver_message = JSON.parse(m)
          end
          if websocket_receiver_message.key? "action"
            handle_command(websocket_receiver_message)
          end

        end

        # EventMachine::PeriodicTimer.new(1) do
        #   log "pub"
        #   # @client.publish("/websocket/receiver",{action: "blas_gwapo"})
        # end

      rescue Error => e
        @logger.info "WebsocketServer::Error: #{e.backtrace}"
        # EM.stop
        # raise
      end
    }
    EM.error_handler { |e|
      @logger.info " WebsocketServer - EM.error_handler: #{ e.backtrace }"

    }

  end



  def handle_command(message,channel=@channel)
    command = message['action']
    log "action #{command}"
    @action_command = command
    valid_commands = %w( push_notif )
    if valid_commands.include? command
      command_method = "#{command}_command"
      method(command_method).call(message)
    end
  end


  def push_notif_command(message)
    user_ids = JSON.parse(message["user_ids"].to_json)
    data = message["data"]
    if !user_ids.nil?
      user_ids.each do |id|
        @client.publish(user_channel(id),data)
        log "send push notif to #{id} data= #{data}"
      end
    end
  end

  def user_channel(user_id)
    "/main/user/#{user_id}"
  end


  def websocket_receiver_channel
    @channel + "/receiver"
  end


end
