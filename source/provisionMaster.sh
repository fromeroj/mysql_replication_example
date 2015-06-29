#!/usr/bin/env bash

source /home/vagrant/source/provision.sh
if [[ ! -e /home/vagrant/.provision ]];then
    update_system
    setup_mysql
    sudo /etc/init.d/mysqld stop
    sudo sed -i 's/\[mysqld_safe\]/bind-address = 192.168.20.100\nserver-id = 100\nlog_bin = \/var\/log\/mysql\/mysql-bin.log\nbinlog_do_db = example\n[mysqld_safe]/' /etc/my.cnf
    sudo /etc/init.d/mysqld start
    echo "done" > /home/vagrant/.provision
fi

