#!/bin/bash
PATH=/usr/bin:/usr/local/bin:$PATH
#1.Add user to run the app
sudo useradd -m -d /home/railsplay railsplay -s /bin/bash
#2.Next, Upgrade the system and install in case something missing
curl -sL https://deb.nodesource.com/setup_8.x | sudo -E bash -
curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | sudo apt-key add -
echo "deb https://dl.yarnpkg.com/debian/ stable main" | sudo tee /etc/apt/sources.list.d/yarn.list
sudo apt-get update -y
sudo apt-get install -y git git-core zlib1g-dev build-essential libssl-dev libreadline-dev libyaml-dev libsqlite3-dev sqlite3 libxml2-dev libxslt1-dev libcurl4-openssl-dev python-software-properties libffi-dev nodejs
#3.cd to new user's home dir and clone the remote repository to the new user's home dir 
sudo su - railsplay -c "git clone https://github.com/nataliiapakhol/railsplay.git blog"
#4.Install ruby 2.5.1(used version while creating)
cd /home/railsplay
sudo su railsplay -c "wget http://ftp.ruby-lang.org/pub/ruby/2.5/ruby-2.5.1.tar.gz"
sudo su railsplay -c "tar -xzvf ruby-2.5.1.tar.gz"
cd /home/railsplay/ruby-2.5.1
sudo su railsplay -c "./configure"
sudo su railsplay -c "/usr/bin/make"
sudo make install
#5.Install Bundler&Rails
sudo gem install bundler
cd /home/railsplay/blog
bundle install
sudo su railsplay -c "rails db:migrate RAILS_ENV=development"
#6.Copy systemd service script to the corect dir
sudo cp /home/railsplay/blog/provision/railsapp.service /etc/systemd/system/railsapp.service
sudo systemctl enable railsapp.service
sudo systemctl start railsapp.service

