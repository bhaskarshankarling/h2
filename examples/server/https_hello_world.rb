#!/usr/bin/env ruby
# Run with: bundle exec examples/server/https_hello_world.rb

require 'bundler/setup'
require 'h2/server'

port       = 1234
addr       = Socket.getaddrinfo('localhost', port).first[3]
certs_dir  = File.expand_path '../../../tmp/certs', __FILE__

tls = {
  cert: certs_dir + '/server.crt',
  key:  certs_dir + '/server.key',
  # :extra_chain_cert => certs_dir + '/chain.pem'
}

puts "*** Starting server on https://#{addr}:#{port}"

s = H2::Server::HTTPS.new host: addr, port: port, **tls do |connection|
  connection.each_stream do |stream|
    stream.goaway_on_complete

    if stream.request.path == '/favicon.ico'
      stream.respond :not_found
    else
      stream.respond :ok, "hello, world!\n"
    end
  end
end

sleep
