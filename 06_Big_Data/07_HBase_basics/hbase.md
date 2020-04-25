# Big Data

Explore HBase  

2020.04.18  

## Create AWS EC2

Launch Ubuntu Server 18.04 LTS, t2.2xlarge, 100 Gb, allow Port Range = 1-65535 for your IP.

Copy your .ppk file from Windows into WSL

```bash
cp /mnt/c/your_directory/your_key.ppk ~/ 
```

Update .ppk permissions from 777 to 

```bash
sudo chmod your_key.ppk 700
```

Connect to the instance from WSL (or whatever you prefer) and accept the new connection.

Login as Ubuntu

### Install docker

Instructions found [here](https://phoenixnap.com/kb/how-to-install-docker-on-ubuntu-18-04).

```bash
ubuntu@ip-172-31-14-89:~$ sudo apt-get update

ubuntu@ip-172-31-14-89:~$ sudo apt install docker.io

# if you want docker to launch on startup
ubuntu@ip-172-31-14-89:~$ sudo systemctl start docker

# if you want docker to launch on startup
ubuntu@ip-172-31-14-89:~$ sudo systemctl enable docker 
```

### Install Cloudera docker quickstart

Instruction found [here](https://docs.cloudera.com/documentation/enterprise/5-16-x/topics/quickstart_docker_container.html).

```bash
ubuntu@ip-172-31-14-89:~$ sudo docker pull cloudera/quickstart:latest

ubuntu@ip-172-31-14-89:~$ sudo docker images 
REPOSITORY            TAG                 IMAGE ID            CREATED             SIZE
cloudera/quickstart   latest              4239cd2958c6        4 years ago         6.34GB

ubuntu@ip-172-31-14-89:~$ sudo docker run --hostname=quickstart.cloudera --privileged=true -t -i -p 7180:7180 -p 80:80 -p 8888:8888 -p 7187:7187 4239cd2958c6 /usr/bin/docker-quickstart
```

Look good?

```bash
[root@quickstart /]# exit
ubuntu@ip-172-31-14-89:~$ 
```

## HBase Part 1

### Start HBase

Instructions found [here](https://hub.docker.com/r/avapno/apache-phoenix). 

```bash
ubuntu@ip-172-31-14-89:~$ sudo docker pull avapno/apache-phoenix:latest

# Start docker container
ubuntu@ip-172-31-14-89:~$ sudo docker run -it --name phoenix -p 8765:8765 avapno/apache-phoenix

# cd to hbase directory (optional)
[root@cca5958d9e93 bin]# cd /usr/local/hbase/bin/

# start hbase shell
[root@cca5958d9e93 bin]# hbase shell
hbase(main):001:0>
```

### Basic HBase Commands

Try some basic commands.

```bash
hbase(main):001:0> version
1.2.5, rd7b05f79dee10e0ada614765bb354b93d615a157, Wed Mar  1 00:34:48 CST 2017

hbase(main):001:0> list
TABLE
SYSTEM.CATALOG
SYSTEM.FUNCTION
SYSTEM.MUTEX
SYSTEM.SEQUENCE
SYSTEM.STATS
5 row(s) in 0.1680 seconds

=> ["SYSTEM.CATALOG", "SYSTEM.FUNCTION", "SYSTEM.MUTEX", "SYSTEM.SEQUENCE", "SYSTEM.STATS"]

hbase(main):002:0> help
...
```

Create some tables

```bash

hbase(main):015:0> create 'tab1', {NAME => 'cf1'}
0 row(s) in 1.2610 seconds

=> Hbase::Table - tab1

hbase(main):001:0> create 'tab2', {NAME => 'cf1', VERSIONS => 1}
0 row(s) in 1.3980 seconds

=> Hbase::Table - tab2
hbase(main):002:0> create 'tab3', {NAME => 'cf1'},{NAME => 'cf2', VERSIONS => 4}
0 row(s) in 1.2430 seconds

=> Hbase::Table - tab3
```

Insert data into tables.

```bash
hbase(main):001:0> put 'tab1', 'rk1', 'cf1:cl1', 'value'
0 row(s) in 0.0210 seconds

hbase(main):001:0> scan 'tab1'
ROW                                COLUMN+CELL
 rk1                               column=cf1:cl1, timestamp=1541261596009, value=value
1 row(s) in 0.0800 seconds
```

Insert a new row and change the version number 

```bash
hbase(main):002:0> put 'tab1', 'rk2', 'cf1:cl1', 'good', 23
0 row(s) in 0.0570 seconds

hbase(main):003:0> scan 'tab1'
ROW                                              COLUMN+CELL
 rk1                                             column=cf1:cl1, timestamp=1587237325697, value=value
 rk2                                             column=cf1:cl1, timestamp=23, value=good
2 row(s) in 0.0140 seconds
```

Get data from hbase table.

```bash
hbase(main):012:0> get 'tab1', 'rk1'
COLUMN                                           CELL
 cf1:cl1                                         timestamp=1587237325697, value=value
1 row(s) in 0.0190 seconds

hbase(main):013:0> get 'tab1', 'rk1', {COLUMN => 'cf1:cl1'}
COLUMN                                           CELL
 cf1:cl1                                         timestamp=1587237325697, value=value
1 row(s) in 0.0050 seconds

hbase(main):014:0> get 'tab1', 'rk1', {COLUMN => 'cf1:cl1', VERSIONS=> 2}
COLUMN                                           CELL
 cf1:cl1                                         timestamp=1587237325697, value=value
1 row(s) in 0.0030 seconds
```

## Hbase Part 2

### Some more basic HBase commands

Create table and insert data.

```bash
# the below needs capitalization for a later phoenix view to work. the view sits on top this table
hbase(main):001:0> create 'USERS', 'ENAME','photo'
put 'USERS', 'Skrahimi', 'ENAME:FNAME', 'Saeed'
put 'USERS', 'Skrahimi', 'ENAME:LNAME', 'Rahimi'
put 'USERS', 'Bsmisra', 'ENAME:LNAME', 'Misra'
put 'USERS', 'Bsmisra', 'ENAME:MI', 'S'
put 'USERS', 'Skrahimi', 'ENAME:MI', 'K'
put 'USERS', 'Bsrubin', 'ENAME:FNAME', 'Brad'
put 'USERS', 'Bsrubin', 'ENAME:LNAME', 'Rubin'
put 'USERS', 'Bsmisra', 'ENAME:LNAME', 'Misra'
put 'USERS', 'Bsmisra', 'ENAME:MI', 'S'
put 'USERS', 'Skrahimi', 'ENAME:FNAME', 'SAEED'
0 row(s) in 2.4040 seconds

# the echoes below do not reflect my latest change of uppercasing table and field names
=> Hbase::Table - users
hbase(main):002:0> put 'users', 'Skrahimi', 'ename:fname', 'Saeed'
0 row(s) in 0.1210 seconds

hbase(main):003:0> put 'users', 'Skrahimi', 'ename:lname', 'Rahimi'
0 row(s) in 0.0060 seconds

hbase(main):004:0> put 'users', 'Bsmisra', 'ename:lname', 'Misra'
0 row(s) in 0.0030 seconds

hbase(main):005:0> put 'users', 'Bsmisra', 'ename:mi', 'S'
0 row(s) in 0.0030 seconds

hbase(main):006:0> put 'users', 'Skrahimi', 'ename:mi', 'K'
0 row(s) in 0.0020 seconds

hbase(main):007:0> put 'users', 'Bsrubin', 'ename:fname', 'Brad'
0 row(s) in 0.0020 seconds

hbase(main):008:0> put 'users', 'Bsrubin', 'ename:lname', 'Rubin'
0 row(s) in 0.0020 seconds

hbase(main):009:0> put 'users', 'Bsmisra', 'ename:lname', 'Misra'
0 row(s) in 0.0030 seconds

hbase(main):010:0> put 'users', 'Bsmisra', 'ename:mi', 'S'
0 row(s) in 0.0020 seconds

hbase(main):011:0> put 'users', 'Skrahimi', 'ename:fname', 'SAEED'
0 row(s) in 0.0030 seconds
```

Get specific rows.

```bash
hbase(main):002:0* get 'users', 'Skrahimi'
COLUMN                                           CELL
 ename:fname                                     timestamp=1587237947937, value=SAEED
 ename:lname                                     timestamp=1587237947803, value=Rahimi
 ename:mi                                        timestamp=1587237947870, value=K
3 row(s) in 0.1960 seconds

hbase(main):003:0> get 'users', 'Skrahimi', 'ename:fname'
COLUMN                                           CELL
 ename:fname                                     timestamp=1587237947937, value=SAEED
1 row(s) in 0.0050 seconds

hbase(main):004:0> put 'users', 'Skrahimi', 'ename:fname', 'Sam'
0 row(s) in 0.0470 second
```

Query based on specific criteria.

```bash
hbase(main):001:0> scan 'users',{COLUMNS => 'ename:lname'}
ROW                                              COLUMN+CELL
 Bsmisra                                         column=ename:lname, timestamp=1587237947912, value=Misra
 Bsrubin                                         column=ename:lname, timestamp=1587237947898, value=Rubin
 Skrahimi                                        column=ename:lname, timestamp=1587237947803, value=Rahimi
3 row(s) in 0.1970 seconds

hbase(main):002:0> scan 'users',{STARTROW => 'Skrahimi',STOPROW => 'Bsrubin'}
ROW                                              COLUMN+CELL
0 row(s) in 0.0050 seconds
```

Count users.

```bash
hbase(main):001:0> count 'users'
3 row(s) in 0.1920 seconds

=> 3
hbase(main):002:0> count 'users', 3
Current count: 3, row: Skrahimi
3 row(s) in 0.0040 seconds

=> 3
```

#### DML

Delete data in a table.

```bash
hbase(main):001:0> delete 'tab1', 'rk1', 'cf1:cl1'
0 row(s) in 0.2060 seconds

hbase(main):002:0> deleteall 'tab1', 'rk1'
0 row(s) in 0.0020 seconds
```

Huh...0 rows deleted?

#### DDL

Drop a table.

```bash
hbase(main):003:0> disable 'tab2'
0 row(s) in 2.4830 seconds

hbase(main):004:0> drop 'tab2'
0 row(s) in 1.2480 seconds
```

Alter table for adding column family.

```bash
hbase(main):011:0> alter 'tab1', NAME => 'f1', VERSIONS => 5
Updating all regions with the new schema...
1/1 regions updated.
Done.
0 row(s) in 1.9160 seconds
```

Delete a column family.

```bash
# long form
# hbase(main):017:0> alter 'tab1', NAME => 'f1', METHOD => 'delete'

# short form
hbase(main):017:0> alter 'tab1', 'delete' => 'f1'
Updating all regions with the new schema...
1/1 regions updated.
Done.
0 row(s) in 1.9000 seconds
```

#### Reference Variables

Create a table and a reference variable to it.

```bash
hbase(main):023:0> v1 = create 'test', 'cf1'
0 row(s) in 1.2300 seconds

=> Hbase::Table - test
hbase(main):024:0>
hbase(main):025:0* v1.put 'rk1', 'cf1:fname', 'Saeed'
0 row(s) in 0.0670 seconds
hbase(main):026:0>
hbase(main):027:0* v1.put 'rk1', 'cf1:lname', 'Rahimi'
0 row(s) in 0.0020 seconds
hbase(main):028:0>
hbase(main):029:0* v1.put 'rk1', 'cf1:hobby', 'Golf'
0 row(s) in 0.0020 seconds
hbase(main):030:0>
hbase(main):031:0* v1.scan
ROW                                              COLUMN+CELL
 rk1                                             column=cf1:fname, timestamp=1587239300484, value=Saeed
 rk1                                             column=cf1:hobby, timestamp=1587239300528, value=Golf
 rk1                                             column=cf1:lname, timestamp=1587239300511, value=Rahimi
1 row(s) in 0.0440 seconds
```

Reference variable to an existing table.

```bash
hbase(main):001:0> v2 = get_table 'test'
0 row(s) in 0.0350 seconds

=> Hbase::Table - test
hbase(main):002:0>
hbase(main):003:0* v2.scan
ROW                                              COLUMN+CELL
 rk1                                             column=cf1:fname, timestamp=1587239300484, value=Saeed
 rk1                                             column=cf1:hobby, timestamp=1587239300528, value=Golf
 rk1                                             column=cf1:lname, timestamp=1587239300511, value=Rahimi
1 row(s) in 0.1880 seconds
```

### Start Phoenix

> Phoenix is an open source SQL skin for HBase. You use the standard JDBC APIs instead of the regular HBase client APIs to create tables, insert data, and query your HBase data. [source](https://phoenix.apache.org/Phoenix-in-15-minutes-or-less.html)

```bash
# cd to phoenix
[root@cca5958d9e93 bin]# cd /usr/local/phoenix/bin/

# Connect to phoenix sqlline
[root@cca5958d9e93 bin]# 0: sqlline.py

# alternatively, simply '/usr/local/phoenix/bin/sqlline.py'
jdbc:phoenix:localhost:2181:/hbase>
```

**Note:** Press **Ctrl-D** to [quit](http://hadooptutorial.info/apache-phoenix-hbase-an-sql-layer-on-hbase/) phoenix. 

##### Map and query existing HBase “users” table.

1. Map a “view” on the HBase table:

   > Phoenix supports updatable views on top of tables with the unique feature leveraging the schemaless capabilities of HBase of being able to add columns to them. All views all share the same underlying physical HBase table and may even be indexed independently. 

   For more directions on this, see the [documentation](http://phoenix.apache.org/faq.html).

   > Note that you don’t need the double quotes if you create your HBase table with all caps names (since this is how Phoenix normalizes strings, by upper casing them).

```bash
# We are creating a view on top of an existing hbase table.
0: jdbc:phoenix:localhost:2181:/hbase> CREATE VIEW "users" (pk VARCHAR PRIMARY KEY, "ename"."fname" VARCHAR, "ename"."lname" VARCHAR);
No rows affected (5.898 seconds)

# alternatively-
# CREATE VIEW USERS1 (pk VARCHAR PRIMARY KEY, ENAME.val VARCHAR, PHOTO.val VARCHAR);
```

2. Query the view

```bash
# the below query didn't work because I didn't capitalize the tables puts above
0: jdbc:phoenix:localhost:2181:/hbase> SELECT ename as "EName"
	FROM USERS;
Error: ERROR 1012 (42M03): Table undefined. tableName=USERS (state=42M03,code=1012)
```

##### Create a table, populate the table and query the table.

1. Create a table:

```sql
0: jdbc:phoenix:localhost:2181:/hbase> CREATE TABLE IF NOT EXISTS us_population (
      state CHAR(2) NOT NULL,
      city VARCHAR NOT NULL,
      population BIGINT
      CONSTRAINT my_pk PRIMARY KEY (state, city));
No rows affected (2.282 seconds)
```

2. Populate the table

[Upsert](http://phoenix.apache.org/language/index.html#upsert_values) is not a type. 

> Inserts if not present and updates otherwise the value in the table.

Be sure to [use single quotes](https://stackoverflow.com/a/37377821/5825523) where appropriate.

```sql
0: jdbc:phoenix:localhost:2181:/hbase> UPSERT INTO US_POPULATION(state, city, population) VALUES('NY', 'New York', 8143197);
1 row affected (0.043 seconds)
0: jdbc:phoenix:localhost:2181:/hbase> UPSERT INTO US_POPULATION(state, city, population) VALUES('CA', 'Los Angeles', 3844829);
1 row affected (0.004 seconds)
0: jdbc:phoenix:localhost:2181:/hbase> UPSERT INTO US_POPULATION(state, city, population) VALUES('IL', 'Chicago', 2842518);
1 row affected (0.003 seconds)
0: jdbc:phoenix:localhost:2181:/hbase> UPSERT INTO US_POPULATION(state, city, population) VALUES('TX', 'Houston', 2016582);
1 row affected (0.003 seconds)
0: jdbc:phoenix:localhost:2181:/hbase> UPSERT INTO US_POPULATION(state, city, population) VALUES('PA', 'Philadelphia', 1463281);
1 row affected (0.003 seconds)
0: jdbc:phoenix:localhost:2181:/hbase> UPSERT INTO US_POPULATION(state, city, population) VALUES('AZ', 'Phoenix', 1461575);
1 row affected (0.009 seconds)
0: jdbc:phoenix:localhost:2181:/hbase> UPSERT INTO US_POPULATION(state, city, population) VALUES('TX', 'San Antonio', 1256509);
1 row affected (0.003 seconds)
0: jdbc:phoenix:localhost:2181:/hbase> UPSERT INTO US_POPULATION(state, city, population) VALUES('CA', 'San Diego', 1255540);
1 row affected (0.003 seconds)
0: jdbc:phoenix:localhost:2181:/hbase> UPSERT INTO US_POPULATION(state, city, population) VALUES('TX', 'Dallas', 1213825);
1 row affected (0.003 seconds)
0: jdbc:phoenix:localhost:2181:/hbase> UPSERT INTO US_POPULATION(state, city, population) VALUES('CA', 'San Jose', 912332);
1 row affected (0.004 seconds)
```

3. Query the data

```sql
0: jdbc:phoenix:localhost:2181:/hbase> SELECT state as "State", count(city) as "City Count", sum(population) as "Population Sum"
. . . . . . . . . . . . . . . . . . .> FROM us_population
. . . . . . . . . . . . . . . . . . .> GROUP BY state
. . . . . . . . . . . . . . . . . . .> ORDER BY sum(population) DESC;
+--------+-------------+-----------------+
| State  | City Count  | Population Sum  |
+--------+-------------+-----------------+
| NY     | 1           | 8143197         |
| CA     | 3           | 6012701         |
| TX     | 3           | 4486916         |
| IL     | 1           | 2842518         |
| PA     | 1           | 1463281         |
| AZ     | 1           | 1461575         |
+--------+-------------+-----------------+
6 rows selected (0.04 seconds)
```

Exit, exit, exit. **Terminate the EC2 instance**.

