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

def echo_server(endpoint)
	condition = Async do |task|
		task.sleep 60 while true
	end

	graceful_server(endpoint, condition) do |client, task:|
		# This is an asynchronous block within the current reactor:
		while data = client.read(512)
			# This produces out-of-order responses.
			task.sleep(rand * 0.01)

			client.write(data.reverse)
		end
	ensure
		client.close
	end

	return condition
end

def echo_client(endpoint, data)
	Async do |task|
		endpoint.connect do |peer|
			10.times do
				Async.logger.info "Client #{data}: sleeping"
				task.sleep 2

				result = peer.write(data)
				message = peer.read(512)

				Async.logger.info "Sent #{data}, got response: #{message}"
			end
		end
	end
end

Async do |task|
	endpoint = Async::IO::Endpoint.tcp('0.0.0.0', 9000)

	Async.logger.info "Starting server..."
	server = echo_server(endpoint)

	Async.logger.info "Clients connecting..."
	1.times.collect do |i|
		echo_client(endpoint, "Hello World #{i}")
	end

	task.sleep 5

	Async.logger.info "Stopping server..."
	server.stop
end

Async.logger.info "Finished..."
