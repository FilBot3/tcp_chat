require "tcp_chat/version"

module TcpChat
  # The Client class, used to connect to the TCP Chat Server.
	class Client
    def initialize( server )
			# Assign the FQDN or IP of the server to connect to
      @server = server
      @request = nil
      @response = nil
      listen
      send
			# Start all threads and don't wait for htem to end
      @request.join
			# Start all the threads and don't wait for them to end.
      @response.join
    end
		
		# This method starts a thread listening for the server, 
		# and display the message from it.
    def listen
      @response = Thread.new do
        loop {
          msg = @server.gets.chomp
          puts "#{msg}"
        }
      end
    end
		
		# Send a message to the server to everyone listening on 
		# the other end of the server. 
    def send
      puts "Enter the username:"
      @request = Thread.new do
        loop {
          msg = $stdin.gets.chomp
          @server.puts( msg )
        }
      end
    end
  end

  class Server
    def initialize( port, ip )
			# Create a TCP Server, listing on an IP, and a port.
      @server = TCPServer.open( ip, port )
			# Create a Hash to hold the connections. 
      @connections = Hash.new
			# Create a hash to hold the rooms in the chat server.
      @rooms = Hash.new
			# Create a hash to hold the connected clients. 
      @clients = Hash.new
			# Populate the Connections hash with certain values.
			# :server holds the TCP Server information. 
      @connections[:server] = @server
			# Populate the connections hash with the rooms hash. 
      @connections[:rooms] = @rooms
			# Populate the connections hash with the connected clients hash. 
      @connections[:clients] = @clients
			# Start the server in an unending loop
      run
    end

    def run
      loop {
				# Start a Thread, if the server accepts a connection
        Thread.start(@server.accept) do | client |
					# From the server connection, get the nick_name of the connected user.
          nick_name = client.gets.chomp.to_sym
					# for each client connected, check to see fi they're already conencted, 
					# if so, just disconnect them and show an error. 
          @connections[:clients].each do |other_name, other_client|
            if nick_name == other_name || client == other_client
              client.puts "This username already exist"
							# Cut the TCP Server Connection thread.
              Thread.kill self
            end
          end
					# Show the nickname and their IP of who's connected.
          puts "#{nick_name} #{client}"
					# Assign the conencted to a slot in the connections' client nickname list
          @connections[:clients][nick_name] = client
          client.puts "Connection established, Thank you for joining! Happy chatting"
					# Check to see if the users have sent any messages and display them. 
          listen_user_messages( nick_name, client )
        end
			}.join # Run all the threads without waiting for them to end. 
    end

    def listen_user_messages( username, client )
			# Basically start another thread in a thread displaying the messages being sent. 
      loop {
        msg = client.gets.chomp
        @connections[:clients].each do |other_name, other_client|
          unless other_name == username
            other_client.puts "#{username.to_s}: #{msg}"
          end
        end
      }
    end
  end
end
