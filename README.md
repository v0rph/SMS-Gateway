SMS Gateway
===========

TODO Simple text about the project ^_^

* First install gammu and gammu sms daemon 

  $ sudo apt-get install gammu gammu-smsd

* Install mysql

  $ sudo apt-get install mysql-server mysql-client

* Install mysql gem

  $ gem install mysql -- --with-mysql-config=/usr/bin/mysql_config

* Import gammu db

  $ mysqladmin -u root -p create sms
  $ gunzip -c /usr/share/doc/gammu/examples/sql/mysql.sql.gz | mysql -u yourmysqluser -p -h localhost sms

* Create new config

  $ cp config/config.yml.sample config/config.yml

* Edit config #to-do auto config

  $ vim config/config.yml
  place your own mysql username and password  
  under phones edit with your own
               "deviceIMEI": "deviceOperator"

* To config gammu mysql connection open the config file, find [smsd] and replace user=yourmysqluser and password=yourmysqlpassword with your own

  $ vim config/gammu-smsd

* Phone config file goes to ~/.sms/ #datafolder

  $ mkdir ~/.sms/ #datafolder
  $ cp config/gammu-smsd ~/.sms/ #to datafolder

* Install ruby rubygems and sinatra

  $ sudo apt-get install ruby rubygems
  $ gem install sinatra

* Plug in devices

* Run app.rb
  $ ruby app.rb

* Example post can be found in massMsg.html
  
  open in browser to send mass messages
  $ firefox massMsg.html
  or
  $ google-chrome massMsg.html

* USE WITH CARE!
* By default behaviour, all phone messages present in the phone will be copied to mysql database and then WIPED FROM THE PHONE!

