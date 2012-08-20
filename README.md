SMS Gateway
===========

TODO Simple text about the project ^_^

First install gammu and gammu sms daemon 

    $ sudo apt-get install gammu gammu-smsd

Install mysql

    $ sudo apt-get install mysql-server mysql-client libmysqlclient-dev

Import gammu db

    $ mysqladmin -u root -p create sms

    $ gunzip -c /usr/share/doc/gammu/examples/sql/mysql.sql.gz | mysql -u yourmysqluser -p -h localhost sms

Create new config

    $ cp config/config.yml.sample config/config.yml

Edit config #to-do auto config

    $ vim config/config.yml
  place your own mysql username and password  
  under phones edit with your own
               "deviceIMEI": "deviceOperator"

To config gammu mysql connection open the config file, find [smsd] and replace user=yourmysqluser and password=yourmysqlpassword with your own

    $ vim config/gammu-smsdrc

Phone config file goes to ./tmp/ #datafolder

    $ mkdir ./tmp/ #datafolder
  
    $ cp config/gammu-smsdrc ./tmp/ #to datafolder

Install ruby ruby-dev rubygems and sinatra

    $ sudo apt-get install ruby ruby-dev rubygems
  
    $ gem install sinatra --no-ri --no-rdoc

Install mysql gem

    $ gem install mysql -- --with-mysql-config=/usr/bin/mysql_config


Plug in devices

Run app.rb

    $ ruby app.rb

Example post can be found in massMsg.html
  
  open in browser to send mass messages

    $ firefox massMsg.html

  or

    $ google-chrome massMsg.html

Additional Notes:
* USE WITH CARE!
* By default behaviour, all phone messages present in the phone will be copied to mysql database and then WIPED FROM THE PHONE!
* Don't use root as mysql user, create another user
