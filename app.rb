#!/usr/bin/env ruby
$LOAD_PATH << './lib'

require 'rubygems'
require 'sinatra'
require 'yaml'

require 'gateway.rb'

#set :run true
#set :bind '0.0.0.0'

@@config = YAML.load_file("config/config.yml")
@@gateway = Gateway.new @@config

# post is {user, key, message, numbers[]}
post '/form' do
  user = @@config['users'][params[:user]]
  #user = nil
  return "Invalid User" unless user
  #return params[:user] unless user
  return(if user['password'] == params[:key]
    params[:numbers].each do |number|       
      if @@gateway.send(user['behaviour'], number, params[:message])
        puts number
        puts "Sent"
      else
        puts number
        puts "Invalid Number"
      end
    end
  else 
    "Invalid Password"
  end)
end

get '/form' do
  File.read(File.join('public', 'massMsg.html'))
end
