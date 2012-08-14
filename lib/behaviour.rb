module Behaviour
  require 'mysql'
  # selects phone from given behaviour
  def self.select_phone(number, behaviour, sqldata)
    #self.send(behaviour['type'], number, behaviour['options'])
    case behaviour['type']
    when "pt_single"
      return pt_single(number,behaviour['options'])
    when "pt_default"
      phone = pt_default(number, behaviour['options'])
      if (check_limits(phone, behaviour, sqldata) == 1)
        return phone
      else
        if (phone == behaviour['default'])
          return 'warning' #limits have been reached
        else
          return behaviour['default']
        end
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
  
  def self.check_limits(number , behaviour, sqldata)
    def_phone = pt_checkphoneid(number)
    raise ArgumentError, "Bad number" if def_phone == "Invalid Number"
    count = behaviour['options'][def_phone][0..-2]
    timespan = behaviour['options'][def_phone].split('').last
    mysqluser = sqldata['user']
    mysqlpassword = sqldata['password']
    case timespan
    when /w|W|s|S/
      #weekly / semanal
      #check number of sent items by week -> select Count(ID) from sentitems where  Week(SendingDateTime) = Week(Now()) AND Year(SendingDateTime) = Year(Now());
      db = Mysql.real_connect('localhost', mysqluser, mysqlpassword, 'sms');
      rs = db.query 'Select ID from sentitems where Week(SendingDateTime) = Week(Now()) AND Year(SendingDateTime) = Year(Now());'
      n_rows = rs.num_rows
      puts "There are #{n_rows} rows in the result set"
      #n_rows.times do
      #  puts rs.fetch_row.join("\s")
      #end
    when /M|m/
      #montly / mensal
      db = Mysql.real_connect('localhost', mysqluser, mysqlpassword, 'sms');
      rs = db.query 'Select ID from sentitems where Month(SendingDateTime) = Month(Now()) AND Year(SendingDateTime) = Year(Now());'
      n_rows = rs.num_rows
      puts "There are #{n_rows} rows in the result set"

    when /D|d/
      #daily / diario
      # check number of sent items by day -> select Count(ID) from sentitems where DayOfYear(SendingDateTime) = DayOfYear(Now());
      db = Mysql.real_connect('localhost', mysqluser, mysqlpassword, 'sms');
      rs = db.query 'select ID from sentitems where DayOfYear(SendingDateTime) = DayOfYear(Now());'
      n_rows = rs.num_rows
      puts "There are #{n_rows} rows in the result set"
    else
      #!!badconfig!!
      return -2
    end
    if (n_rows < Integer(count))
      return 1
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
