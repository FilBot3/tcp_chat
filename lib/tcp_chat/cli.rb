require "thor"
require "socket"
require "tcp_chat"

module TcpChat
  class CLI < Thor 
    desc "client SERVER PORT", "Connect to a SERVER on PORT"
    def client(server, port)
      chat_server = TCPSocket.open( "#{server}", port)
      TcpChat::Client.new( chat_server )
    end

    desc "server PORT", "Start a TCP Chat server on PORT"
    def server(port)
      TcpChat::Server.new( port, "localhost" )
    end
  end
end
