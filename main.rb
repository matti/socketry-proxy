require 'async'
require 'async/io'

Async.logger.info!

GRACE_TIME = 5

def graceful_server(endpoint, condition = nil, &block)
	Async do |parent_task|
		server_tasks = []

		Async.logger.info "Binding to #{endpoint}..."

		endpoint.each do |endpoint|
			server = endpoint.bind
			server.listen(Socket::SOMAXCONN)

			Async.logger.info "Accepting connections from #{server}..."
			server_tasks << parent_task.async do
				server.accept_each(task: parent_task, &block)
			ensure
				server.close
			end
		end

		if condition
			Async.logger.info "Waiting on #{condition}..."
			condition.wait

			Async.logger.info("Task tree"){|buffer| parent_task.print_hierarchy(buffer)}

			Async.logger.info "Stopping #{server_tasks.count} accept loops..."
			server_tasks.each(&:stop)

			children = parent_task.children

			Async.logger.info "Stopping #{children.count} connections..."

			if children.any?
				Async.logger.warn("Waiting for #{children.count} connections...")

				parent_task.with_timeout(GRACE_TIME) do
					children.each(&:wait)
				rescue Async::TimeoutError
					Async.logger.warn("Could not terminate child connections...")
				end
			end

			children = parent_task.children

			if children.any?
				Async.logger.warn("Stopping #{children.count} connections...")

				children.each(&:stop)
			end
		end
	end
end


def proxy_server(endpoint, endpoint_upstream)
	condition = Async do |task|
		task.sleep 60 while true
	end
	connections = {}
	upstream_read_size = 0
	client_read_size = 0

	counts = {
		errno_eprototype: 0,
		errno_epipe: 0,
		errno_econnrefused: 0,
		connections: 0
	}
	Async do |task|
		loop do
			p [
					"conns", connections.size,
					"connh", counts[:connections],
					"eprot", counts[:errno_eprototype],
					"epipe", counts[:errno_epipe],
					"econr", counts[:errno_econnrefused],
					"urs", upstream_read_size,
					"crs", client_read_size
				]
			task.sleep 0.1
		end
	end

	graceful_server(endpoint, condition) do |client, task:|
		connections[client.object_id] = true
		counts[:connections] += 1
		# This is an asynchronous block within the current reactor:
		endpoint_upstream.connect do |upstream|
			uptream_reader_task = task.async do
				while data_from_upstream = upstream.read(1024)
					upstream_read_size = data_from_upstream.size
					client.write data_from_upstream
				end
			rescue Errno::EPROTOTYPE
				counts[:errno_eprototype] =+ 1
				# ?? mac?
			rescue Errno::EPIPE
				counts[:errno_epipe] =+ 1
				# Client lost?
			rescue Errno::ECONNREFUSED
				counts[:errno_econnrefused] =+ 1

				print "."
				task.sleep 0.1
				retry
			end

			begin
				while data_for_upstream = client.read(1024)
					client_read_size = data_for_upstream.size

					upstream.write data_for_upstream
				end
			rescue Errno::ECONNRESET
				print "E"
			end
		ensure
			#Async.logger.info "closing upstream reader task ..."
			uptream_reader_task.stop
			#Async.logger.info "closing connection to upstream ..."
			upstream.close
		end

	ensure
		connections.delete client.object_id
		client.close
	end
end


Async do |task|
	endpoint = Async::IO::Endpoint.tcp('0.0.0.0', 9000)
	endpoint_upstream = Async::IO::Endpoint.parse ARGV[0]

	Async.logger.info "Starting server..."
	server = proxy_server(endpoint, endpoint_upstream)

#	server.stop
end

Async.logger.info "Finished..."
