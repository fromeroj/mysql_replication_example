#!/usr/bin/env bash
echo "Stopping slave and creating fresh backup"
vagrant ssh slave1 -c "mysql -u root -p123456 example -e 'STOP SLAVE'"
vagrant ssh master -c "mysql -u root -p123456 -e \"grant replication slave on *.* TO 'slave1'@'192.168.20.101' identified by '123456';flush privileges;\""
POS=$(vagrant ssh master -c ' mysql -u root -p123456 example -e "FLUSH TABLES WITH READ LOCK;SHOW MASTER STATUS;"' | grep mysql-bin | cut -d'|' -f3 | sed -e 's/ //g')
vagrant ssh master -c "mysqldump -u root -p123456 --opt example > /home/vagrant/source/example${POS}.sql"
vagrant ssh master -c "mysql -u root -p123456 -e 'UNLOCK TABLES'"
echo "Recreating SLAVE and starting it"
vagrant ssh slave1 -c "mysql -u root -p123456 -e 'drop database example; create database example';"
vagrant ssh slave1 -c "mysql -u root -p123456 example < ~/source/example${POS}.sql"
vagrant ssh slave1 -c "mysql -u root -p123456 -e \"CHANGE MASTER TO MASTER_HOST='192.168.20.100',MASTER_USER='slave1', MASTER_PASSWORD='123456', MASTER_LOG_FILE='mysql-bin.000001', MASTER_LOG_POS=${POS}; START SLAVE\""
rm -f source/example${POS}.sql
vagrant ssh slave1 -c "mysql -u root -p123456 example -e 'SHOW SLAVE STATUS'"
echo "Creating example table on master and adding an element"
vagrant ssh master -c "mysql -u root -p123456 example -e \"CREATE TABLE IF NOT EXISTS tbl_example( id INT NOT NULL AUTO_INCREMENT,  PRIMARY KEY(id),  name VARCHAR(30),   age INT); insert into tbl_example (name,age) values ('A',1);\""
echo "Showing the results in slave"
vagrant ssh slave1 -c "mysql -u root -p123456 example -e 'select * from tbl_example'";
