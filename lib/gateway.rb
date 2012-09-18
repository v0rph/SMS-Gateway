#!/usr/bin/env ruby
#sms gateway script
require 'behaviour.rb'

class Gateway
  def initialize(config, options={:initialize_gammu => true})
    raise ArgumentError, "config should be a hash"           unless config.is_a? Hash
    raise ArgumentError, "config is dead?!"                  unless @@config     = config
    raise ArgumentError, "options[:phones] is missing."      unless @phones      = config['phones']
    raise ArgumentError, "options[:ports] is missing."       unless @ports       = config['ports'].split(";")
    raise ArgumentError, "options[:datafolder] is missing."  unless @datafolder  = config['datafolder']
    raise ArgumentError, "options[:mysql] is missing"        unless @sqldata     = config['mysql']
    unless options[:initialize_gammu] == false
      phoneloader
      start
      clearbukkit
    end
  end

  #loads phones that are connected, recreates config files
  def phoneloader
    raise IOError, "config file could not be read" unless template = IO.read( @datafolder + "gammu-smsdrc")
    @ports.each do |port|
      IO.write((@datafolder + port), template.gsub("%port",port))
      imei = `gammu -c #{@datafolder + port} --identify | grep IMEI`.split(/\s/).last
      if @phones.keys.include?(imei)
        IO.write((@datafolder + @phones[imei]), IO.read(@datafolder + port).gsub("%phone",@phones[imei]))
      end
      system "rm #{@datafolder + port}"
    end
  end

  # kills gammu daemons, initiates new
  def start 
    `killall gammu-smsd` && puts("Killing Daemons!")
    puts "Loading Daemons......"
    @phones.values.each do |provider|
      fork do
        exec "gammu-smsd -c #{@datafolder+provider} &"
      end
    end
  end

  #sends message to specified phone, if none specified identifies prefered phone
  def send(user, number, message, phone=nil)
    behaviour = @@config['users'][user]['behaviour']
    return "Invalid User" unless behaviour
    phone = Behaviour.select_phone(number, behaviour, @sqldata) #if phone.nil?
    if @phones.values.include?(phone) #se fizer match com os existentes
      `gammu-smsd-inject -c #{@datafolder}#{phone} TEXT #{number} -text "#{message}"` # send to daemon
      #LOGIT que foi para a fila
    else
      if phone == "bukkit"
        bukkit(user,number,message)
      end
    end
  end

  def clearbukkit()
    puts "Atempting to send pending messages in bukkit(tm)"
    sleep(1)
    return "no bukkit" unless File.exists?("./tmp/bukkit")
    list = IO.read("./tmp/bukkit").split("\n")
    `rm ./tmp/bukkit`
    list.each do |l|
      bad =0;
      bad=1 unless user = l.split("`")[0]
      bad=1 unless number = l.split("`")[1]
      bad=1 unless message = l.split("`")[2]
      puts user
      puts number
      puts message
      if (bad==0)
        send(user,number,message)
      end
    end
  end

  def bukkit(user,number,message)
    IO.append("./tmp/bukkit",user+"`"+number+"`#{message}\n")
  end

end

class IO
  def self.write(filepath, text)
    File.open(filepath, "w") { |f| f << text }
  end

  def self.append(filepath, text)
    File.open(filepath, "a+") { |f| f << text }
  end

end
