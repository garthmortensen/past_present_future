# Big Data  

## HBase

2020.05.09  

### Objectives

Setup an EC2 on AWS, install docker on it, run a Cloudera image, and launch HBase.

In HBase, create some tables, insert data, alter data, delete data. Notice that you don't need to create an actual database.

### Setup

#### Create AWS EC2

Launch Ubuntu Server 18.04 LTS, t2.2xlarge, 100 Gb (**this might be overkill, but big data comes with steep requirements**), allow Port Range = 1-65535 for your IP.  

Connect to the instance from WSL/Git Bash/PUTTY and accept the new connection.  

Login as Ubuntu.  

#### Install docker

Instructions found [here](https://phoenixnap.com/kb/how-to-install-docker-on-ubuntu-18-04).

```bash
# update the box
ubuntu@ip-172-31-14-89:~$ sudo apt-get update
# install docker
ubuntu@ip-172-31-14-89:~$ sudo apt install docker.io
# if you want docker to launch on startup
ubuntu@ip-172-31-14-89:~$ sudo systemctl start docker
# if you want docker to launch on startup
ubuntu@ip-172-31-14-89:~$ sudo systemctl enable docker 
```

#### Install Cloudera docker quickstart

Instruction found [here](https://docs.cloudera.com/documentation/enterprise/5-16-x/topics/quickstart_docker_container.html).

```bash
# download cloudera image
ubuntu@ip-172-31-14-89:~$ sudo docker pull cloudera/quickstart:latest

# check which images are available
ubuntu@ip-172-31-14-89:~$ sudo docker images 
REPOSITORY            TAG                 IMAGE ID            CREATED             SIZE
cloudera/quickstart   latest              4239cd2958c6        4 years ago         6.34GB

# run it
ubuntu@ip-172-31-14-89:~$ sudo docker run --hostname=quickstart.cloudera --privileged=true -t -i -p 7180:7180 -p 80:80 -p 8888:8888 -p 7187:7187 4239cd2958c6 /usr/bin/docker-quickstart
```

Look good?

```bash
[root@quickstart /]# exit
ubuntu@ip-172-31-14-89:~$ 
```

Now that Cloudera's docker image is running, we can now HBase into it.

### HBase 

#### Start HBase

Instructions found [here](https://hub.docker.com/r/avapno/apache-phoenix). 

```bash
# grab phoenix
ubuntu@ip-172-31-14-89:~$ sudo docker pull avapno/apache-phoenix:latest
# Start docker container
ubuntu@ip-172-31-14-89:~$ sudo docker run -it --name phoenix -p 8765:8765 avapno/apache-phoenix
# cd to hbase directory (optional)
[root@cca5958d9e93 bin]# cd /usr/local/hbase/bin/
# start hbase shell
[root@cca5958d9e93 bin]# hbase shell
hbase(main):001:0>
```

#### Play with the Data

##### DDL - Create tables, column families

Create a user table consisting of column families:  

1. "bio"
   ● bio can have 2 versions.
   ● bio can have the following columns: fname, lname, age
2. "likes"
   ● like can have 6 versions.
   ● like can have the following columns: pet, activity

```bash
# create the table and define the column families
hbase(main):031:0> create 'user', 'bio', 'likes'
# add a new column family, and specify version count it can have
hbase(main):032:0> alter 'user', NAME => 'bio', VERSIONS => 2
hbase(main):033:0> alter 'user', NAME => 'likes', VERSIONS => 6
# add new columns to the column families
hbase(main):034:0> alter 'user', 'bio', {NAME => 'fname'}, {NAME => 'lname'}, {NAME => 'age'}
hbase(main):035:0> alter 'user', 'likes', {NAME => 'pet'}, {NAME => 'activity'}
```

Check the results.

```bash
# describe the table
hbase(main):001:0> describe 'user'
Table user is ENABLED
user
COLUMN FAMILIES DESCRIPTION
{NAME => 'activity', BLOOMFILTER => 'ROW', VERSIONS => '1', IN_MEMORY => 'false', KEEP_DELETED_CELLS => 'FALSE', DATA_BLOCK_ENCODING => 'NONE', TTL => 'FOREVER', COMPRESSION => 'NONE', MIN_
VERSIONS => '0', BLOCKCACHE => 'true', BLOCKSIZE => '65536', REPLICATION_SCOPE => '0'}
{NAME => 'age', BLOOMFILTER => 'ROW', VERSIONS => '1', IN_MEMORY => 'false', KEEP_DELETED_CELLS => 'FALSE', DATA_BLOCK_ENCODING => 'NONE', TTL => 'FOREVER', COMPRESSION => 'NONE', MIN_VERSI
ONS => '0', BLOCKCACHE => 'true', BLOCKSIZE => '65536', REPLICATION_SCOPE => '0'}
{NAME => 'bio', BLOOMFILTER => 'ROW', VERSIONS => '2', IN_MEMORY => 'false', KEEP_DELETED_CELLS => 'FALSE', DATA_BLOCK_ENCODING => 'NONE', TTL => 'FOREVER', COMPRESSION => 'NONE', MIN_VERSI
ONS => '0', BLOCKCACHE => 'true', BLOCKSIZE => '65536', REPLICATION_SCOPE => '0'}
{NAME => 'fname', BLOOMFILTER => 'ROW', VERSIONS => '1', IN_MEMORY => 'false', KEEP_DELETED_CELLS => 'FALSE', DATA_BLOCK_ENCODING => 'NONE', TTL => 'FOREVER', COMPRESSION => 'NONE', MIN_VER
SIONS => '0', BLOCKCACHE => 'true', BLOCKSIZE => '65536', REPLICATION_SCOPE => '0'}
{NAME => 'likes', BLOOMFILTER => 'ROW', VERSIONS => '6', IN_MEMORY => 'false', KEEP_DELETED_CELLS => 'FALSE', DATA_BLOCK_ENCODING => 'NONE', TTL => 'FOREVER', COMPRESSION => 'NONE', MIN_VER
SIONS => '0', BLOCKCACHE => 'true', BLOCKSIZE => '65536', REPLICATION_SCOPE => '0'}
{NAME => 'lname', BLOOMFILTER => 'ROW', VERSIONS => '1', IN_MEMORY => 'false', KEEP_DELETED_CELLS => 'FALSE', DATA_BLOCK_ENCODING => 'NONE', TTL => 'FOREVER', COMPRESSION => 'NONE', MIN_VER
SIONS => '0', BLOCKCACHE => 'true', BLOCKSIZE => '65536', REPLICATION_SCOPE => '0'}
{NAME => 'pet', BLOOMFILTER => 'ROW', VERSIONS => '1', IN_MEMORY => 'false', KEEP_DELETED_CELLS => 'FALSE', DATA_BLOCK_ENCODING => 'NONE', TTL => 'FOREVER', COMPRESSION => 'NONE', MIN_VERSI
ONS => '0', BLOCKCACHE => 'true', BLOCKSIZE => '65536', REPLICATION_SCOPE => '0'}
7 row(s) in 0.2420 seconds
```

*What's strange to me is that VERSIONS => 'X' are strange numbers. One is 2, another 6, the remaining 1. Even after rerunning ALTER TABLE to update the values, these numbers remain*. Otherwise, it looks good!  

##### DML - Insert Rows

Load the following data into the table. For the rowkey, use fname_lname.

| fname | lname | age  | pet  | activity |
| ----- | ----- | ---- | ---- | -------- |
| user  | one   | 1    | cat  | cry      |
| user  | two   | 2    |      | walk     |
| user  | three |      | dog  | bike     |
| user  | four  |      |      | eat      |

```bash
# put '<table name>','row1','<colfamily:colname>','<value>'
# user_one
put 'user', 'user_one', 'bio:fname', 'user'
put 'user', 'user_one', 'bio:lname', 'one'
put 'user', 'user_one', 'bio:age', '1'
put 'user', 'user_one', 'likes:pet', 'cat'
put 'user', 'user_one', 'likes:activity', 'cry'
# user_two
put 'user', 'user_two', 'bio:fname', 'user'
put 'user', 'user_two', 'bio:lname', 'two'
put 'user', 'user_two', 'bio:age', '2'
put 'user', 'user_two', 'likes:activity', 'walk'
# user_three
put 'user', 'user_three', 'bio:fname', 'user'
put 'user', 'user_three', 'bio:lname', 'three'
put 'user', 'user_three', 'likes:pet', 'dog'
put 'user', 'user_three', 'likes:activity', 'bike'
# user_four
put 'user', 'user_four', 'bio:fname', 'user'
put 'user', 'user_four', 'bio:lname', 'four'
put 'user', 'user_four', 'likes:activity', 'eat'
```

Check results.

```bash
hbase(main):038:0> scan 'user'
ROW                               COLUMN+CELL
 user_four                        column=bio:fname, timestamp=1589061415327, value=user
 user_four                        column=bio:lname, timestamp=1589061415340, value=four
 user_four                        column=likes:activity, timestamp=1589061417030, value=eat
 user_one                         column=bio:age, timestamp=1589061381743, value=1
 user_one                         column=bio:fname, timestamp=1589061381717, value=user
 user_one                         column=bio:lname, timestamp=1589061381732, value=one
 user_one                         column=likes:activity, timestamp=1589061382966, value=cry
 user_one                         column=likes:pet, timestamp=1589061381753, value=cat
 user_three                       column=bio:fname, timestamp=1589061407104, value=user
 user_three                       column=bio:lname, timestamp=1589061407119, value=three
 user_three                       column=likes:activity, timestamp=1589061408122, value=bike
 user_three                       column=likes:pet, timestamp=1589061407130, value=dog
 user_two                         column=bio:age, timestamp=1589061389705, value=2
 user_two                         column=bio:fname, timestamp=1589061389678, value=user
 user_two                         column=bio:lname, timestamp=1589061389695, value=two
 user_two                         column=likes:activity, timestamp=1589061390246, value=walk
4 row(s) in 0.0280 seconds
```

All rows inserted!  

##### DDL & DML - Add Column & Insert Rows

Insert this new row into the table. The new column “gender” belongs in the “bio” column family.

| fname | lname | age  | gender | pet  | activity |
| ----- | ----- | ---- | ------ | ---- | -------- |
| user  | five  | 5    | m      | cat  | sleep    |

```bash
# add new column
hbase(main):039:0> alter 'user', 'bio', {NAME => 'gender'}
Updating all regions with the new schema...
0/1 regions updated.
1/1 regions updated.
Done.
Updating all regions with the new schema...
1/1 regions updated.
Done.
0 row(s) in 5.2690 seconds

# insert row
# user_five
put 'user', 'user_five', 'bio:fname', 'user'
put 'user', 'user_five', 'bio:lname', 'five'
put 'user', 'user_five', 'bio:age', '5'
put 'user', 'user_five', 'bio:gender', 'm'
put 'user', 'user_five', 'likes:pet', 'cat'
put 'user', 'user_five', 'likes:activity', 'sleep'
```

Check results.

```bash
hbase(main):007:0> scan 'user'
ROW                              COLUMN+CELL
 user_five                       column=bio:age, timestamp=1589061861376, value=5
 user_five                       column=bio:fname, timestamp=1589061861317, value=user
 user_five                       column=bio:gender, timestamp=1589061861410, value=m
 user_five                       column=bio:lname, timestamp=1589061861353, value=five
 user_five                       column=likes:activity, timestamp=1589061862956, value=sleep
 user_five                       column=likes:pet, timestamp=1589061861428, value=cat
 user_four                       column=bio:fname, timestamp=1589061415327, value=user
 user_four                       column=bio:lname, timestamp=1589061415340, value=four
 user_four                       column=likes:activity, timestamp=1589061417030, value=eat
 user_one                        column=bio:age, timestamp=1589061381743, value=1
 user_one                        column=bio:fname, timestamp=1589061381717, value=user
 user_one                        column=bio:lname, timestamp=1589061381732, value=one
 user_one                        column=likes:activity, timestamp=1589061382966, value=cry
 user_one                        column=likes:pet, timestamp=1589061381753, value=cat
 user_three                      column=bio:fname, timestamp=1589061407104, value=user
 user_three                      column=bio:lname, timestamp=1589061407119, value=three
 user_three                      column=likes:activity, timestamp=1589061408122, value=bike
 user_three                      column=likes:pet, timestamp=1589061407130, value=dog
 user_two                        column=bio:age, timestamp=1589061389705, value=2
 user_two                        column=bio:fname, timestamp=1589061389678, value=user
 user_two                        column=bio:lname, timestamp=1589061389695, value=two
 user_two                        column=likes:activity, timestamp=1589061390246, value=walk
5 row(s) in 0.0400 seconds
```

All rows inserted!  

##### DDL & DML - Add Column Family & Delete Rows

Add a new column family name “dislike” to that table. The “dislike” column family can have 1
version.

```bash
# add a new column family, and specify version count it can have
hbase(main):032:0> alter 'user', NAME => 'dislike', VERSIONS => 1
```

Check the results.

```bash
hbase(main):002:0> describe 'user'
Table user is ENABLED
user
COLUMN FAMILIES DESCRIPTION
{NAME => 'activity', BLOOMFILTER => 'ROW', VERSIONS => '1', IN_MEMORY => 'false', KEEP_DELETED_CELLS => 'FALSE', DATA_BLOCK_ENCODING => 'NONE', TTL => 'FOREVER', COMPRESSION => 'NONE', MIN_
VERSIONS => '0', BLOCKCACHE => 'true', BLOCKSIZE => '65536', REPLICATION_SCOPE => '0'}
{NAME => 'age', BLOOMFILTER => 'ROW', VERSIONS => '1', IN_MEMORY => 'false', KEEP_DELETED_CELLS => 'FALSE', DATA_BLOCK_ENCODING => 'NONE', TTL => 'FOREVER', COMPRESSION => 'NONE', MIN_VERSI
ONS => '0', BLOCKCACHE => 'true', BLOCKSIZE => '65536', REPLICATION_SCOPE => '0'}
{NAME => 'bio', BLOOMFILTER => 'ROW', VERSIONS => '2', IN_MEMORY => 'false', KEEP_DELETED_CELLS => 'FALSE', DATA_BLOCK_ENCODING => 'NONE', TTL => 'FOREVER', COMPRESSION => 'NONE', MIN_VERSI
ONS => '0', BLOCKCACHE => 'true', BLOCKSIZE => '65536', REPLICATION_SCOPE => '0'}
{NAME => 'fname', BLOOMFILTER => 'ROW', VERSIONS => '1', IN_MEMORY => 'false', KEEP_DELETED_CELLS => 'FALSE', DATA_BLOCK_ENCODING => 'NONE', TTL => 'FOREVER', COMPRESSION => 'NONE', MIN_VER
SIONS => '0', BLOCKCACHE => 'true', BLOCKSIZE => '65536', REPLICATION_SCOPE => '0'}
{NAME => 'gender', BLOOMFILTER => 'ROW', VERSIONS => '1', IN_MEMORY => 'false', KEEP_DELETED_CELLS => 'FALSE', DATA_BLOCK_ENCODING => 'NONE', TTL => 'FOREVER', COMPRESSION => 'NONE', MIN_VE
RSIONS => '0', BLOCKCACHE => 'true', BLOCKSIZE => '65536', REPLICATION_SCOPE => '0'}
{NAME => 'likes', BLOOMFILTER => 'ROW', VERSIONS => '6', IN_MEMORY => 'false', KEEP_DELETED_CELLS => 'FALSE', DATA_BLOCK_ENCODING => 'NONE', TTL => 'FOREVER', COMPRESSION => 'NONE', MIN_VER
SIONS => '0', BLOCKCACHE => 'true', BLOCKSIZE => '65536', REPLICATION_SCOPE => '0'}
{NAME => 'lname', BLOOMFILTER => 'ROW', VERSIONS => '1', IN_MEMORY => 'false', KEEP_DELETED_CELLS => 'FALSE', DATA_BLOCK_ENCODING => 'NONE', TTL => 'FOREVER', COMPRESSION => 'NONE', MIN_VER
SIONS => '0', BLOCKCACHE => 'true', BLOCKSIZE => '65536', REPLICATION_SCOPE => '0'}
{NAME => 'pet', BLOOMFILTER => 'ROW', VERSIONS => '1', IN_MEMORY => 'false', KEEP_DELETED_CELLS => 'FALSE', DATA_BLOCK_ENCODING => 'NONE', TTL => 'FOREVER', COMPRESSION => 'NONE', MIN_VERSI
ONS => '0', BLOCKCACHE => 'true', BLOCKSIZE => '65536', REPLICATION_SCOPE => '0'}
8 row(s) in 0.2470 seconds
```

The empty column family doesn't show up since it's empty. Looks good!  

Delete user_three from the table.

```bash
# delete '<table name>', '<row>', '<column name>', '<time stamp>'
hbase(main):001:0> deleteall 'user', 'user_three'
0 row(s) in 0.2170 seconds
```

Check the results.

```bash
hbase(main):001:0> scan 'user'
ROW                         COLUMN+CELL
 user_five                  column=bio:age, timestamp=1589061861376, value=5
 user_five                  column=bio:fname, timestamp=1589061861317, value=user
 user_five                  column=bio:gender, timestamp=1589061861410, value=m
 user_five                  column=bio:lname, timestamp=1589061861353, value=five
 user_five                  column=likes:activity, timestamp=1589061862956, value=sleep
 user_five                  column=likes:pet, timestamp=1589061861428, value=cat
 user_four                  column=bio:fname, timestamp=1589061415327, value=user
 user_four                  column=bio:lname, timestamp=1589061415340, value=four
 user_four                  column=likes:activity, timestamp=1589061417030, value=eat
 user_one                   column=bio:age, timestamp=1589061381743, value=1
 user_one                   column=bio:fname, timestamp=1589061381717, value=user
 user_one                   column=bio:lname, timestamp=1589061381732, value=one
 user_one                   column=likes:activity, timestamp=1589061382966, value=cry
 user_one                   column=likes:pet, timestamp=1589061381753, value=cat
 user_two                   column=bio:age, timestamp=1589061389705, value=2
 user_two                   column=bio:fname, timestamp=1589061389678, value=user
 user_two                   column=bio:lname, timestamp=1589061389695, value=two
 user_two                   column=likes:activity, timestamp=1589061390246, value=walk
4 row(s) in 0.2180 seconds
```

Exit, exit, exit.  

**Terminate the EC2 instance**.

