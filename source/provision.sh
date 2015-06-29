#!/usr/bin/env bash

function update_system () {
    echo "Updating system and getting necessary packages"
#    sudo yum -y update
#    sudo yum -y upgrade
    sudo yum -y install mysql-server mysql expect
    sudo chkconfig mysqld on
    sudo /etc/init.d/mysqld start
    sudo mkdir /var/log/mysql/
    sudo chown mysql /var/log/mysql/
}

function setup_mysql () {
    function setup_mysql__usage () {
        cat <<EOF
Usage:
    ${FUNCNAME[ 1 ]}
      [ -R|--root-pass <password> ]
      [ -D|--database  <database_name> ]
      [ -U|--user     <database user> ]
      [ -P|--pass     <database user password ]
      [ -?|--help ]
EOF
    }
    local root_pass="123456"
    local database="example"
    local user="example"
    local pass="123456"

   local ARGS=$(getopt -o R:D:U:P: \
        --long root-pass:,database:,user:,pass:,help\
        -n "${FUNCNAME[ 0 ]}" -- "$@")

    if [ $? -ne 0 ]; then
        echo "${FUNCNAME[ 0 ]} 001 invalid arguments"
        return
    fi
    eval set -- "$ARGS"
    while true ; do
        case "$1" in
            -R|--root-pass)
                local root_pass="$2" ; shift 2 ;;
            -D|--database)
                local database="$2" ; shift 2 ;;
            -U|--user)
                local user="$2" ; shift 2 ;;
            -P|--pass)
                local pass="$2" ; shift 2 ;;
            --) shift ; break ;;
            *)
                setup_mysql__usage
                return ;;
        esac
    done
    echo " Setting mysql root pass to :((${root_pass}))"
    expect -- << EOF
spawn sudo mysql_secure_installation
expect "Enter current password for root (enter for none):"
send "\r"
expect {
"Set root password?" {
send "y\r"
expect "New password:"
send "${root_pass}\r"
expect "Re-enter new password:"
send "${root_pass}\r"
expect "Remove anonymous users?"
send "y\r"
expect "Disallow root login remotely?"
send "y\r"
expect "Remove test database and access to it?"
send "y\r"
expect "Reload privilege tables now?"
send "y\r"
exp_continue
}
"ERROR" {
send \003
exp_continue
}
}
EOF
    echo "Setting up mysql database: [${database}]"
    echo "with user:[${user}]  and password:[${pass}]"
    mysql -u root -p123456 -e "create database ${database} CHARACTER SET utf8 COLLATE utf8_unicode_ci;"
    echo "CREATE USER ${user}@localhost IDENTIFIED BY '${pass}';"
    mysql -u root -p123456 -e "CREATE USER ${user}@localhost IDENTIFIED BY '${pass}';"
    mysql -u root -p123456 -e "GRANT ALL PRIVILEGES ON ${database}.* TO ${user}@localhost;"
}
