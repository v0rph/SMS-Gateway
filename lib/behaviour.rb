module Behaviour
  require 'mysql'

  # selects phone from given behaviour
  def self.select_phone(number, behaviour, sqldata)
    case behaviour['type']
      when "pt_single"
        return pt_single(number,behaviour['options'])
      when "pt_default"
        phone = pt_default(number, behaviour['options'])
        if ((check_limits(phone, behaviour, sqldata) >= 1)||(phone == 'Invalid Number'))
          return phone
        else
          return 'bukkit'
        end
    end
  end
  
 private
   
  def self.pt_single(number, options)
    if pt_checkphoneid(number) 
      a = Hash.new
      a = options['phones']
      if a.value?(options['phone'])
        return options['phone']
      else
        return "Invalid Phone in config"     #badconfig!!
      end
    else
      nil
    end
  end

  def self.pt_default(number, options)
    pt_checkphoneid(number)
  end
  
  def self.check_limits(def_phone , behaviour, sqldata)
    if def_phone == "Invalid Number"
      #raise ArgumentError, "Bad number"
      return -1
    end
    count = behaviour['options'][def_phone][0..-2]
    timespan = behaviour['options'][def_phone].split('').last
    mysqluser = sqldata['user']
    mysqlpassword = sqldata['password']
    case timespan
    when /w|W|s|S/
      #weekly / semanal
      db = Mysql.real_connect('localhost', mysqluser, mysqlpassword, 'sms');
      rs = db.query 'Select ID from sentitems where Week(SendingDateTime) = Week(Now()) AND Year(SendingDateTime) = Year(Now()) AND SenderID like '+"\""+def_phone+"\""+';'
      n_rows = rs.num_rows
      puts "There are #{n_rows} rows in the result set"
    when /M|m/
      #montly / mensal
      db = Mysql.real_connect('localhost', mysqluser, mysqlpassword, 'sms');
      rs = db.query 'Select ID from sentitems where Month(SendingDateTime) = Month(Now()) AND Year(SendingDateTime) = Year(Now()) AND SenderID like '+"\""+def_phone+"\""+';'
      n_rows = rs.num_rows
      puts "There are #{n_rows} rows in the result set"

    when /D|d/
      #daily / diario
      db = Mysql.real_connect('localhost', mysqluser, mysqlpassword, 'sms');
      rs = db.query 'select ID from sentitems where DayOfYear(SendingDateTime) = DayOfYear(Now()); AND SenderID like '+"\""+def_phone+"\""+';'
      n_rows = rs.num_rows
      puts "There are #{n_rows} rows in the result set"
    else
      #!!badconfig!!
      return -2
    end
    db = Mysql.real_connect('localhost',mysqluser,mysqlpassword,'sms');
    rs = db.query 'Select ID from outbox where SenderID like '+"\""+def_phone+"\""+';'
    queued = rs.num_rows
    if ((n_rows < Integer(count)) && (queued < Integer(count) - n_rows ))
      return Integer(count) - n_rows
    else
      return -1
    end
  end

  # validate number and check id, returns which operator/phoneid should send this message
  def self.pt_checkphoneid( number )
    case number
      when /^(\+351)?91[0-9]{7}$/
        phone = "vodafone"
      when /^(\+351)?9(6|2)[0-9]{7}$/
        phone = "tmn"
      when /^(\+351)?93[0-9]{7}$/
        phone = "optimus"
      else 
        return "Invalid Number"
    end
  end
end
