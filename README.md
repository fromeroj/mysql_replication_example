# mysql_replication_example
Mysql replication example, over 2 vagrant Centos 6.5 boxes

This is an example of mysql replication using a slave and a master
you need firts to add the box:
```
vagrant box add centos6.5 https://github.com/2creatives/vagrant-centos/releases/download/v6.5.3/centos65-x8
6_64-20140116.box
```
Then run 

```
vagrant up
```

And finally

```
bash enslave.sh
```
