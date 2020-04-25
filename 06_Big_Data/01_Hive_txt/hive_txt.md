# Big Data

Hive queries on .txt

2020.02.14  

In this exercise, we launch and connect to a VM which contains **Hortonworks HDP 2.6.5**. We then WinSCP a log file into the VM, and transfer it into the Hadoop Filesystem (HDFS). Following that, we launch Ambari and enter Hive View, where we create an External Table. The table takes an apache_log.txt file as input, and forms it into a table. Finally, we write a few simple queries as an introduction to Hive syntax.

## Connect to Hadoop Cluster

### Connect to the VM

Open virtualbox and launch your image. Open your terminal of choice and ssh to the virtual machine (VM). Switch user to hdfs.

```bash
garth@Cyberfuchi5:~$ ssh root@sandbox-hdp.hortonworks.com -p 2222
[root@sandbox-hdp ~]# su hdfs
```

### Restart Ambari Services

If this is your first boot, you may need to restart many of Ambari's services, and turn the remaining into Maintenance Mode. Services which I needed to restart include:

* HDFS
* YARN
* MapReduce
* Hive
* ZooKeeper
* Ranger (security). I had to restart this twice for some fucking reason.

All others were placed into Maintenance Mode. This process takes about 20 minutes.

### Transfer Files

Open WinSCP and connect to the VM using root@sandbox-hdp.hortonworks.com. Drag and drop the file into the VM.

> apache_logs.txt

Create the HDFS directory.

**Now this is tricky.** What's going on is that you are creating in the hadoop filesystem the directory. You're not creating the directory in the vm. If you were creating it in the VM, it would just be "[hdfs@sandbox-hdp root]$ mkdir -p /tmp/test/apache_logs"

But that's not your goal. Your goal is to create it in the hadoop cluster. To do that, you need to run a hadoop command, on the file system fs. While still logged into the cluster, recursively change permissions on the folder. After that, you'll be able to transfer the file into the folder.

```shell
[root@sandbox-hdp ~]# su hdfs
[hdfs@sandbox-hdp root]$ hadoop fs -mkdir -p /tmp/test/apache_logs
[hdfs@sandbox-hdp root]$ hadoop fs -chmod -R 777 /tmp/test/
[hdfs@sandbox-hdp root]$ hadoop fs -ls /tmp/test/
```

Without chmod, we wouldn't be able to write files into the directory. With folder created and permissions changed,1 we can now transfer files into the folder.

You can't transfer from sandbox to cluster when you are logged into cluster. After exit, transfer into cluster.

```shell
[hdfs@sandbox-hdp root]$ exit
[root@sandbox-hdp ~]# hadoop fs -put apache_logs.txt /tmp/test/apache_logs
```

Log back in.

```bash
[root@sandbox-hdp ~]# su hdfs
[hdfs@sandbox-hdp root]$ hadoop fs -chmod -R 777 /tmp/test/
```

**Make sure the file permissions are updated, otherwise you'll error out.**

Check the file is what we expect. You can't wc directly in hadoop, so you need to pipe the cat through wc.

```bash
[hdfs@sandbox-hdp root]$ hadoop fs -cat /tmp/test/apache_logs/apache_logs.txt | wc -l
1000
```

All 1,000 lines accounted for.

Before digging in, let's check for existing databases.

```bash
[hdfs@sandbox-hdp root]$ hadoop fs -ls /apps/hive/warehouse
drwxrwxrwx   - hive hadoop          0 2018-06-18 15:16 /apps/hive/warehouse/foodmart.db
```

## Create Table

### A note on Managed vs External Tables

The syntax to create a **regular or managed** table is:

```sql
CREATE [External] TABLE 
[LOCATION ‘directory_path’]; -- for external
```

#### Managed Tables

> The tables we have created so far are called managed tables or sometimes called internal tables, because Hive controls the lifecycle of their data (more or less). As we’ve seen, Hive stores the data for these tables in a subdirectory under the directory defined by hive.metastore.warehouse.dir (e.g., /user/hive/warehouse), by default.
>
> **When we drop a managed table (see “Dropping Tables” on page 66), Hive deletes the data in the table.**
>
> **However, managed tables are less convenient for sharing with other tools.** For example, suppose we have data that is created and used primarily by Pig or other tools, but we want to run some queries against it, but not give Hive ownership of the data. We can define an external table that points to that data, but doesn’t take ownership of it.

#### External Tables

> The EXTERNAL keyword tells Hive this table is external and the LOCATION … clause is required to tell Hive where it’s located.
>
> **Because it’s external, Hive does not assume it owns the data. Therefore, dropping the table does not delete the data, although the metadata for the table will be deleted.** There are a few other small differences between managed and external tables, where some HiveQL constructs are not permitted for external tables.
>
> However, it’s important to note that the differences between managed and external tables are smaller than they appear at first. Even for managed tables, you know where they are located, so you can use other tools, hadoop dfs commands, etc., to modify and even delete the files in the directories for managed tables.
>
> Still, a general principle of good software design is to express intent. If the data is shared between tools, then creating an external table makes this ownership explicit.

Navigate to Ambari Hive View at http://127.0.0.1:8080/ and login. If that link gives you trouble, try http://sandbox-hdp.hortonworks.com:8080

If you are using HDP 3.0, you find Hive View in a different place, as discussed [here](https://community.cloudera.com/t5/Support-Questions/Where-is-Hive-View-on-HDP-3/td-p/184372) and illustrated [here](https://www.cloudera.com/tutorials/loading-and-querying-data-with-data-analytics-studio.html). Click into Data Analytics, then compose a new query.

Otherwise, in the top right of Ambari, click the grid icon, and go to Hive View.

Create a table from the apache_log.txt using the following query:

```sql
drop table apache_log;
CREATE EXTERNAL TABLE apache_log
  (
    host STRING
  , identity STRING
  , webuser STRING
  , timer STRING
  , request STRING
  , status STRING
  , size STRING
  , referer STRING
  , agent STRING
  )
ROW FORMAT SERDE "org.apache.hadoop.hive.serde2.RegexSerDe"
WITH SERDEPROPERTIES 
  (
  "input.regex" = "([^ ]*) ([^ ]*) ([^ ]*) (-|\\[[^\\]]*\\]) ([^ \"]*|\"[^\"]*\") (-|[0-9]*) (-|[0-9]*)(?: ([^ \"]*|\"[^\"]*\") ([^ \"]*|\"[^\"]*\"))?",
  "output.format.string" = "%1$s %2$s %3$s %4$s %5$s %6$s %7$s %8$s %9$s"
  )
STORED AS TEXTFILE
LOCATION '/tmp/test/apache_logs/';
```

**It should take 5-10 minutes for the table to create.**

## Query the File

With the table created from the apache log file, we can now run some queries.

```sql
-- 1. Print a description of the apache_log table.
DESCRIBE default.apache_log -- notice that there are no ( )

-- 2. How many times do we see a request with a status of 404?
select count(status)
from default.apache_log -- default has no impact here, as I created the table into default db.
where status = 404;
-- n = 17

-- 3. How many times does the host 83.149.9.216 appear?
select count(host)
from default.apache_log
where host = '83.149.9.216' -- whitespace actually matters!
-- n = 23

-- 4. How many unique hosts are there in this file?
select count(distinct host)
from default.apache_log;
-- n = 220

-- 5. Get the all status code and how many times they appear. Sort the result desc based on the number of times the status code appears.
create table q5 as
select 
	status
	, count(*) as cnt
from default.apache_log
group by status
order by cnt desc;
/*
q5.status	q5.cnt
200	896
301	53
206	17
304	17
404	17
*/

-- 6. Create a new managed table name access from the apache_log table with only the following columns: host, request, status.
create table default.woof as
select 
	host
	, request
	, status
from default.apache_log;
 -- When creating a managed table, don't provide the location (that's for external tble)
```

## Unresolved Issues

2. What is hadoop -fs vs hdfs -fs?
2. What is Kafka? 

> Kafka is a distributed messaging system. The general idea is that you can have N number of "producers" put data (message) on to a queue and you can N number of consumers read data from this queue. It is a big piece in a streaming architecture. 

