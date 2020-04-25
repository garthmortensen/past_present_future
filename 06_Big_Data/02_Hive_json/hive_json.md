# Big Data

Hive queries on .json  

2020.02.23  

In this exercise, we launch and connect to a VM which contains **Hortonworks HDP 2.6.5**. We then perform an API call to obtain a **.json** file, which we then WinSCP into the VM, and transfer it into the Hadoop Filesystem (HDFS). 

We use Hive to then load data from the file into two tables.

1. We parse the .json into a table using "row format serde 'org.apache.hive.hcatalog.data.JsonSerDe'"
2. We parse the .json into a table without row separating. This let's us work with data we don't yet understand the structure of.

In order to create a **Partitioned Table**, we perform a two-step process. 

1. We create two empty staging tables.

2. We insert data into the staging tables from the two base tables, using two different methods per their two different styles.

   * Using the defined data, we simply load data into our final table.

   * Using the undefined json data, we define which key-pairs we want to load into the final table.

Finally, we query these tables.

## Connect to Hadoop Cluster

### Connect to the VM

Open virtualbox and launch your image. Open terminal and ssh to the VM.

```bash
garth@Cyberfuchi5:~$ ssh root@sandbox-hdp.hortonworks.com -p 2222
```

### Restart Ambari Services

If this is your first boot, you may need to restart many of Ambari's services, and turn the remaining into Maintenance Mode. Services which I needed to restart include:

* HDFS
* YARN
* MapReduce
* Hive
* ZooKeeper
* Ranger (security). I had to restart this twice for some fucking reason.

All others were placed into Maintenance Mode. This initial process takes about 20 minutes.

### Transfer Files

The file used here can be directly obtained via the API call:

```python
import requests
import json

# GET data from gov API
url = 'https://www.govtrack.us/api/v2/role?current=true&role_type=senator'
response = requests.get(url)
response = response.json()
senators = response.get('objects')

# Write results to file
file = 'senators.json'
with open(file, 'a') as outfile:
    for s in senators:
        json.dump(s, outfile)
        outfile.write('\n')
```

Once obtained, open WinSCP and connect to the VM using root@sandbox-hdp.hortonworks.com. Drag and drop the file into the VM.

> senators.json

Sample of 3/100 rows:

```json
{"caucus": null, "congress_numbers": [114, 115, 116], "current": true, "description": "Senior Senator for Tennessee", "district": null, "enddate": "2021-01-03", "extra": {"address": "455 Dirksen Senate Office Building Washington DC 20510", "contact_form": "http://www.alexander.senate.gov/public/index.cfm?p=Email", "fax": "202-228-3398", "office": "455 Dirksen Senate Office Building", "rss_url": "http://www.alexander.senate.gov/public/?a=rss.feed"}, "leadership_title": null, "party": "Republican", "person": {"bioguideid": "A000360", "birthday": "1940-07-03", "cspanid": 5, "firstname": "Lamar", "gender": "male", "gender_label": "Male", "lastname": "Alexander", "link": "https://www.govtrack.us/congress/members/lamar_alexander/300002", "middlename": "", "name": "Sen. Lamar Alexander [R-TN]", "namemod": "", "nickname": "", "osid": "N00009888", "pvsid": "15691", "sortname": "Alexander, Lamar (Sen.) [R-TN]", "twitterid": "SenAlexander", "youtubeid": "lamaralexander"}, "phone": "202-224-4944", "role_type": "senator", "role_type_label": "Senator", "senator_class": "class2", "senator_class_label": "Class 2", "senator_rank": "senior", "senator_rank_label": "Senior", "startdate": "2015-01-06", "state": "TN", "title": "Sen.", "title_long": "Senator", "website": "https://www.alexander.senate.gov/public"}
{"caucus": null, "congress_numbers": [114, 115, 116], "current": true, "description": "Senior Senator for Maine", "district": null, "enddate": "2021-01-03", "extra": {"address": "413 Dirksen Senate Office Building Washington DC 20510", "contact_form": "http://www.collins.senate.gov/contact", "fax": "202-224-2693", "office": "413 Dirksen Senate Office Building", "rss_url": "http://www.collins.senate.gov/public/?a=rss.feed"}, "leadership_title": null, "party": "Republican", "person": {"bioguideid": "C001035", "birthday": "1952-12-07", "cspanid": 45738, "firstname": "Susan", "gender": "female", "gender_label": "Female", "lastname": "Collins", "link": "https://www.govtrack.us/congress/members/susan_collins/300025", "middlename": "M.", "name": "Sen. Susan Collins [R-ME]", "namemod": "", "nickname": "", "osid": "N00000491", "pvsid": "379", "sortname": "Collins, Susan (Sen.) [R-ME]", "twitterid": "SenatorCollins", "youtubeid": "SenatorSusanCollins"}, "phone": "202-224-2523", "role_type": "senator", "role_type_label": "Senator", "senator_class": "class2", "senator_class_label": "Class 2", "senator_rank": "senior", "senator_rank_label": "Senior", "startdate": "2015-01-06", "state": "ME", "title": "Sen.", "title_long": "Senator", "website": "https://www.collins.senate.gov"}
{"caucus": null, "congress_numbers": [114, 115, 116], "current": true, "description": "Senior Senator for Texas", "district": null, "enddate": "2021-01-03", "extra": {"address": "517 Hart Senate Office Building Washington DC 20510", "contact_form": "https://www.cornyn.senate.gov/contact", "fax": "202-228-2856", "office": "517 Hart Senate Office Building", "rss_url": "http://www.cornyn.senate.gov/public/?a=rss.feed"}, "leadership_title": "Senate Majority Whip", "party": "Republican", "person": {"bioguideid": "C001056", "birthday": "1952-02-02", "cspanid": 93131, "firstname": "John", "gender": "male", "gender_label": "Male", "lastname": "Cornyn", "link": "https://www.govtrack.us/congress/members/john_cornyn/300027", "middlename": "", "name": "Sen. John Cornyn [R-TX]", "namemod": "", "nickname": "", "osid": "N00024852", "pvsid": "15375", "sortname": "Cornyn, John (Sen.) [R-TX]", "twitterid": "JohnCornyn", "youtubeid": "senjohncornyn"}, "phone": "202-224-2934", "role_type": "senator", "role_type_label": "Senator", "senator_class": "class2", "senator_class_label": "Class 2", "senator_rank": "senior", "senator_rank_label": "Senior", "startdate": "2015-01-06", "state": "TX", "title": "Sen.", "title_long": "Senator", "website": "https://www.cornyn.senate.gov"}
```

Start bash for tab-completion, switch user to hdfs, and create a folder for senators. Change permissions on that folder, and check that permissions have changed.

```shell
[root@sandbox-hdp ~]# bash
[root@sandbox-hdp ~]# su hdfs
[hdfs@sandbox-hdp root]$ hadoop fs -mkdir -p /tmp/test/senators/
[hdfs@sandbox-hdp root]$ hadoop fs -chmod -R 777 /tmp/test/
[hdfs@sandbox-hdp root]$ hadoop fs -ls /tmp/test/
```

Log out of hdfs and transfer from the VM to the cluster.

```shell
[hdfs@sandbox-hdp root]$ exit
[root@sandbox-hdp ~]# hadoop fs -put senators.json /tmp/test/senators
```

Log back in and check permissions. If you don't adjust permissions, you will face errors somewhere south of here.

```bash
[root@sandbox-hdp ~]# su hdfs
[hdfs@sandbox-hdp root]$ hadoop fs -chmod -R 777 /tmp/test/
```

Check the file is what we expect. You can't wc directly in hadoop, so you need to pipe the cat through wc.

```bash
[hdfs@sandbox-hdp root]$ hadoop fs -cat /tmp/test/senators/senators.json | wc -l
100
```

Look good?

Before digging in, let's check for existing databases.

```bash
[hdfs@sandbox-hdp root]$ hadoop fs -ls /apps/hive/warehouse
Found 3 items
drwxrwxrwx   - hive hadoop          0 2018-06-18 15:16 /apps/hive/warehouse/foodmart.db
drwxrwxrwx   - hive hadoop          0 2020-02-22 21:32 /apps/hive/warehouse/q5
drwxrwxrwx   - hive hadoop          0 2020-02-22 21:20 /apps/hive/warehouse/woof
```

Here, I see some previously created managed tables, along with the sample database foodmart.

## Create Tables

Navigate to Ambari Hive View at http://127.0.0.1:8080/ and login. If that link gives you trouble, try http://sandbox-hdp.hortonworks.com:8080

In the top right of Ambari, click the grid icon, and go to Hive View 2.0.

### Create Formatted Table

Create an external table from the apache_log.txt using the following query:

```sql
-- create table using well-defined format
drop table if exists senators;
create external table if not exists default.senators
	(
    caucus string
    , congress_numbers array<int>
    , `current` boolean
    , description string
    , district string
    , enddate string
    , extra struct
    	<address: string
        , contact_form: string
        , fax: string
        , office: string
        , rss_url: string>
    , leadership_title string
    , party string
    , person struct
    	<bioguideid: string
        , birthday: string
        , cspanid: int
        , firstname: string
        , gender: string
        , gender_label: string
        , lastname: string
        , link: string
        , middlename: string
        , name: string
        , namemod: string
        , nickname: string
        , osid: string
        , pvsid: string
        , sortname: string
        , twitterid: string
        , youtubeid: string>
    , phone string
    , role_type string
    , role_type_label string
    , senator_class string
    , senator_class_label string
    , senator_rank string
    , senator_rank_label string
    , startdate string
    , state string
    , title string
    , title_long string
    , website string
	)
 row format serde 'org.apache.hive.hcatalog.data.JsonSerDe'
 location '/tmp/test/senators/';
```

**It should take 5-10 minutes for the table to create.**

#### Query the Formatted Table

We can now query the table we just created from the file.

```sql
-- Find all senior senators' twitterid
select person.twitterid
from senators
where senator_rank = 'senior';

/* n = 50
twitterid
SenAlexander
SenatorCollins
JohnCornyn
SenatorDurbin
...
SenatorFischer
*/
```

### Create Unformatted Table

Use get_json_object() to create an unformatted table from just the json file.

```sql
-- create table using undefined format
drop table if exists senators_json;
create external table if not exists default.senators_json
	(
    json string -- no SerDe parsing at all, just raw json
	)
 location '/tmp/test/senators/';
```

This would have been super useful for parsing our files in the past. Severely disappointed in not knowing about this technique in the past. This lets you query data that you don't necessarily understand the underling data structure of.

#### Query the Unformatted (unparsed) Table

```sql
-- Find MN senators using unparsed table
select get_json_object(json, '$.person.name') as name 
from senators_json 
where get_json_object(json, '$.state') = 'MN'

/*
name
Sen. Tina Smith [D-MN]
Sen. Amy Klobuchar [D-MN]
*/
```

### Partition Tables

From [Programming in Hive](http://shop.oreilly.com/product/0636920023555.do) page 58.

>Partitioning tables changes how Hive structures the data storage. If we create this table
>in the mydb database, there will still be an employees directory for the table:
>	hdfs://master_server/user/hive/warehouse/mydb.db/employees
>
>However, Hive will now create subdirectories reflecting the partitioning structure. For
>example:
>...
>.../employees/**country=CA/state=AB**
>.../employees/**country=CA/state=BC**
>...
>.../employees/**country=US/state=AL**
>.../employees/**country=US/state=AK**
>...
>Yes, those are the actual directory names. The state directories will contain zero or more
>files for the employees in those states...

*You see that? It takes the content, and it splits it into subdirectories, so that you basically just scan files in that folder. I think this is partitioned by country and state.*

>Once created, the partition keys ( country and state , in this case) behave like regular
>columns...
>
>Perhaps the most important reason to partition data is for faster queries. In the previous
>query, which limits the results to employees in Illinois, it is only necessary to scan the
>contents of one directory. Even if we have thousands of country and state directories,
>all but one can be ignored.

It might often be best to create managed partitioned tables, because Hive creates that folder partitioned directory structure for you. If it were an external partitioned table, you would have to manually handle that.

1. Create a new managed table, called “senators_divided”. The table is partitioned by “party”. Its has the following columns: firstname, lastname, state, phone, party.

```sql
-- Prove that the source table is not partitioned.
show partitions senators;
-- java.sql.SQLException: Error while processing statement: FAILED: Execution Error, return code 1 from org.apache.hadoop.hive.ql.exec.DDLTask. Table senators is not a partitioned table
```

It would appear that you cannot [CTAS with partition](https://stackoverflow.com/a/45438075/5825523). 

> CTAS will never work, because of the following restrictions on CTAS:
>
> 1. The target table cannot be a partitioned table.
> 2. The target table cannot be an external table.
> 3. The target table cannot be a list bucketing table.

A normal workflow is you start by creating a staging table, and then load data into a refined or finished table, which contains the partition. 

#### Create Staging Table

```sql
-- create staging table for formatted data
create table senators_divided (
	firstname string
    , lastname string
    , state string
    , phone string
 )
partitioned by (party string);

-- create staging table from unformatted data
create table senators_divided_json
  (
  firstname string
  , lastname string
  , state string
  , phone string
  )
partitioned by (party string);
```

#### Load Data into Final Table

As [documented](https://docs.cloudera.com/documentation/enterprise/5-8-x/topics/impala_create_table.html), "The most convenient layout for partitioned tables is with all the partition key columns at the end."

This requires the following SETs to work:

```sql
-- load data from the formatted staging table into new table
SET hive.exec.dynamic.partition.mode=nonstrict; -- lets you partition on more than just int column
SET hive.exec.dynamic.partition=true;-- enable dynamic table creation

insert overwrite table senators_divided
partition (party)
select
    person.firstname
    , person.lastname
    , state
    , phone
    , party
from senators;

-- load data from the unformatted staging table into new table
SET hive.exec.dynamic.partition.mode=nonstrict;
SET hive.exec.dynamic.partition=true;

insert overwrite table senators_divided_json
partition (party)
select
  get_json_object(json, '$.person.firstname') as firstname
  , get_json_object(json, '$.person.lastname') as lastname
  , get_json_object(json, '$.state') as state
  , get_json_object(json, '$.phone') as phone
  , get_json_object(json, '$.party') as party
from senators_json;
```

#### Query the Final Tables

At this point, both tables contain the same structured format.

Query the table as few more times.

```sql
-- Describe table
describe formatted senators_divided;

/*
col_name	data_type	comment
# col_name	data_type	comment
""	null	null
firstname	string	""
lastname	string	""
state	string	""
phone	string	""
""	null	null
# Partition Information	null	null
# col_name	data_type	comment
""	null	null
party	string	""
""	null	null
# Detailed Table Information	null	null
Database:	default	null
Owner:	admin	null
CreateTime:	Sun Feb 23 03:19:02 UTC 2020	null
LastAccessTime:	UNKNOWN	null
Protect Mode:	None	null
Retention:	0	null
Location:	hdfs://sandbox-hdp.hortonworks.com:8020/apps/hive/warehouse/senators_divided	null
Table Type:	MANAGED_TABLE	null
Table Parameters:	null	null
""	transient_lastDdlTime	1582427942
""	null	null
# Storage Information	null	null
SerDe Library:	org.apache.hadoop.hive.serde2.lazy.LazySimpleSerDe	null
InputFormat:	org.apache.hadoop.mapred.TextInputFormat	null
OutputFormat:	org.apache.hadoop.hive.ql.io.HiveIgnoreKeyTextOutputFormat	null
Compressed:	No	null
Num Buckets:	-1	null
Bucket Columns:	[]	null
Sort Columns:	[]	null
Storage Desc Params:	null	null
""	serialization.format	1
*/

-- Count Republican senators from first table
select 
	count(*) as cnt
from senators_divided
where party = 'Republican';
-- n = 53

-- Count Republican senators from second table
select 
	count(*) as cnt
from senators_divided_json
where party = 'Republican';
-- n = 53
```

## Future Improvements

1. I'd like to read more about managed and external tables, as well as table partitioning.
2. What are virtual columns?
3. Review TEZ
4. ORC files?
5. Vectorization?
6. Denormalization. Thought provoking.

