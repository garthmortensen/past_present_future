# Big Data  

## MongoDB

2020.05.08  

### Objectives

1. Create a database name “exam2” and a collection named “contrib_data” in the exam2 database.
2. Load the collection “contrib_data” using the Contrib_data.csv file in canvas. NOTE: when you load the data, make sure that “TRANSACTION_AMT” field has a datatype of Double.
3. What is the count of records where the transaction_amt is less than $10?
4. Add a new field named "donar_cat" to the collection "Contrib_data". donar_cat field should have a value of "big_fish" if the transaction_amt is greater than or equal to $500 and "small fish" if transaction_amt is less than $500. Print out total amount for each donar_cat as final output.
5. Give the top 5 cmte_received by transaction amount.
6. Give the top 5 cmte_received by transaction amount that candidate 'BACHMANN, MICHELE' gave money to.

## Setup

### Register 

Go to [cloud.mongodb.com](https://cloud.mongodb.com/). MongoDB Atlas Global Cloud Database lets you deploy and operate a fully elastic, HA db.  

[Register](https://www.mongodb.com/download-center?jmp=nav) for a free account. Use a "Shared Cluster" as a free option, and click "Create Cluster". Wait about 5-10 minutes until golden-brown.  

### Setup Security

Atlas requires authentication before you can access the cluster. To do that, we create a database user.  

Under Security on the left, select “Database Access” > Add New Database User. Create an Atlas admin user: admin/admin. For User Privileges, select Atlas admin.  

Now whitelist your IP under Network Access > Add IP Address > Add Current IP Address (and select a timer).  

### Connect

On the left menu, click Clusters > Connect > Connect to MongoDB Compass > Download.  

Install it.  

Connect using the connection string from the Atlas website.  

## Analysis

### Create Database

Create a database named “exam2” and in it, a collection named “contrib_data.”  

This is point and click using the GUI.  

Create Database  

Database Name: "exam2"  

Collection Name: "contrib_data"  

### Load Data

Load the collection “contrib_data” using the Contrib_data.csv file.  

This is point and click using the GUI.  

Click to enter db "exam2" > "contrib_data" > Add data > Import file > .csv > browse to file  

Ensure “TRANSACTION_AMT” field is Double > Import > Done  

## Play with the Data

What is the count of records where the transaction_amt is less than $10?  

```shell
exam2.contrib_data.find({TRANSACTION_AMT: {$lt: 10}})
# or
({TRANSACTION_AMT: {$lt: 10}})
# return 42
```

I'm switching to Mongo Shell for subsequent operations, because it might be easier with text than GUI.

### Connect

On the left menu, click Clusters > Connect > Connect to Mongo Shell > Connect.  

Connect to the db using the connection string provided by Atlas, in powershell/cmd. 

```powershell
C:\Users\garth>cd c:\MongoDB\bin
c:\MongoDB\bin>mongo "mongodb+srv://XXXXX.mongodb.net/test"  --username admin
MongoDB shell version v4.2.6
Enter password:
...
MongoDB server version: 4.2.6
Welcome to the MongoDB shell.
For interactive help, type "help".
For more comprehensive documentation, see
        http://docs.mongodb.org/
Questions? Try the support group
        http://groups.google.com/group/mongodb-user
```

Check to see if the database is still accessible.

```powershell
MongoDB Enterprise Cluster0-shard-0:PRIMARY> show dbs
admin  0.000GB
exam2  0.001GB
local  3.967GB
```

Excellent, then I will proceed. [Use db](https://www.tutorialspoint.com/mongodb/mongodb_create_database.htm) creates and sets current database. It won't show up using _show dbs_ until you've inserted data into the collection, however.  

```powershell
# use exam2 will create the database if it doesnt already exist
MongoDB Enterprise Cluster0-shard-0:PRIMARY> use exam2
switched to db exam2

# don't do the following. It might switch you to a database called contrib_data, which doesnt exist
# MongoDB Enterprise Cluster0-shard-0:PRIMARY> show collections
# contrib_data
# MongoDB Enterprise Cluster0-shard-0:PRIMARY> use contrib_data
# contrib_data
```

Now let's try the query again.  

**Take note that fields are case sensitive.**

```powershell
# db.collection.find()
MongoDB Enterprise Cluster0-shard-0:PRIMARY> db.contrib_data.find({TRANSACTION_AMT: {$lt: 10}}).pretty()
{
        "_id" : ObjectId("5eb69b30b4418519f4a923f5"),
        "CAND_NAME" : "SPECTER, ARLEN",
        "CAND_PTY_AFFILIATION" : "REP",
        "CAND_OFFICE_ST" : "PA",
        "CAND_ST1" : "4111 TIMBER LANE",
        "CAND_CITY" : "PHILADELPHIA",
        "CAND_ST" : "PA",
        "CAND_ZIP" : "19122",
        "CMTE_NM" : "CITIZENS FOR ARLEN SPECTER",
        "CMTE_ST1" : "PO BOX 70980",
        "CMTE_CITY" : "WASHINGTON",
        "CMTE_ST" : "DC",
        "CMTE_ZIP" : "20024",
        "CMTE_TP" : "S",
        "CMTE_PTY_AFFILIATION" : "REP",
        "ORG_TP" : "",
        "CONNECTED_ORG_NM" : "",
        "cmte_received" : "UNITEDHEALTH GROUP INCORPORATED PAC (UNITED FOR HEALTH)",
        "CMTE_ID" : "C00280206",
        "AMNDT_IND" : "A",
        "RPT_TP" : "Q1",
        "TRANSACTION_PGI" : "G",
        "IMAGE_NUM" : "11020184550",
        "TRANSACTION_TP" : "22Z",
        "ENTITY_TP" : "",
        "NAME" : "UNITED HEALTH GROUP INCORPORATED P",
        "CITY" : "HOPKINS",
        "STATE" : "MN",
        "ZIP_CODE" : "55343",
        "EMPLOYER" : "",
        "OCCUPATION" : "",
        "TRANSACTION_DT" : "02272011",
        "TRANSACTION_AMT" : -2000,
        "OTHER_ID" : "C00274431",
        "TRAN_ID" : "SB0503132512368",
        "FILE_NUM" : "727094",
        "MEMO_CD" : "",
        "MEMO_TEXT" : "",
        "SUB_ID" : "1031920120009505016"
...     
```

Excellent. See how I referred to db.contrib_data and not exam2.contrib_data?  

Count the records.

```shell
MongoDB Enterprise Cluster0-shard-0:PRIMARY> db.contrib_data.find({TRANSACTION_AMT: {$lt: 10}}).count()
42
```

There are 42 transaction amounts less than 10.  

Create a new field using the pseudocode

```sql
case
	when transaction_amt >= $500
		then "big_fish"
	when transaction_amt < $500
		then "small_fish"
end as donar_cat
```

As a middle step, let's preview one nicely printed row that we expect to be returned from our query.

I'll write the results to a variable named large_donars.

```powershell
MongoDB Enterprise Cluster0-shard-0:PRIMARY> var large_donars = db.contrib_data.find({TRANSACTION_AMT: {$gte: 500}}).limit(1).pretty()
MongoDB Enterprise Cluster0-shard-0:PRIMARY> large_donars
{
        "_id" : ObjectId("5eb69b30b4418519f4a92204"),
        "CAND_NAME" : "WARREN, ELIZABETH",
        "CAND_PTY_AFFILIATION" : "DEM",
        "CAND_OFFICE_ST" : "MA",
        "CAND_ST1" : "",
        "CAND_CITY" : "BOSTON",
        "CAND_ST" : "",
        "CAND_ZIP" : "",
        "CMTE_NM" : "ELIZABETH FOR MA INC",
        "CMTE_ST1" : "PO BOX 290568",
        "CMTE_CITY" : "BOSTON",
        "CMTE_ST" : "MA",
        "CMTE_ZIP" : "02129",
        "CMTE_TP" : "S",
        "CMTE_PTY_AFFILIATION" : "DEM",
        "ORG_TP" : "",
        "CONNECTED_ORG_NM" : "",
        "cmte_received" : "RUST CONSULTING INC ADMINISTRATIVE EXCELLENCE POLITICAL ACTION COMMITTEE (RUST PAC",
        "CMTE_ID" : "C00500843",
        "AMNDT_IND" : "A",
        "RPT_TP" : "Q1",
        "TRANSACTION_PGI" : "P",
        "IMAGE_NUM" : "12020311894",
        "TRANSACTION_TP" : "22Z",
        "ENTITY_TP" : "",
        "NAME" : "RUST CONSULTING INC ADMINISTRATIVE",
        "CITY" : "MINNEAPOLIS",
        "STATE" : "MN",
        "ZIP_CODE" : "55402",
        "EMPLOYER" : "",
        "OCCUPATION" : "",
        "TRANSACTION_DT" : "03082012",
        "TRANSACTION_AMT" : 500,
        "OTHER_ID" : "C00468223",
        "TRAN_ID" : "SB050914371217659",
        "FILE_NUM" : "782162",
        "MEMO_CD" : "",
        "MEMO_TEXT" : "",
        "SUB_ID" : "1070320120010102620"
}
```

Transaction_amt checks out. Now let's use [aggregation](https://docs.mongodb.com/manual/reference/operator/aggregation/cond/), and [$addFields](https://docs.mongodb.com/manual/reference/operator/aggregation/addFields/) to add a new field.

```shell
MongoDB Enterprise Cluster0-shard-0:PRIMARY> db.contrib_data.aggregate(
	[
		{
			$addFields:
			{
			donar_cat:
				{
				$cond: { if: {$gte: ["$TRANSACTION_AMT", 500] }, then: "big_fish", else: "small_fish"}
				}
			}
		}
	]
).pretty()

{
        "_id" : ObjectId("5ebeecb7d9f2e54c203a8f3a"),
        "CAND_NAME" : "WARREN, ELIZABETH",
        "CAND_PTY_AFFILIATION" : "DEM",
        "CAND_OFFICE_ST" : "MA",
        "CAND_ST1" : "",
        "CAND_CITY" : "BOSTON",
        "CAND_ST" : "",
        "CAND_ZIP" : "",
        "CMTE_NM" : "ELIZABETH FOR MA INC",
        "CMTE_ST1" : "PO BOX 290568",
        "CMTE_CITY" : "BOSTON",
        "CMTE_ST" : "MA",
        "CMTE_ZIP" : "02129",
        "CMTE_TP" : "S",
        "CMTE_PTY_AFFILIATION" : "DEM",
        "ORG_TP" : "",
        "CONNECTED_ORG_NM" : "",
        "cmte_received" : "RUST CONSULTING INC ADMINISTRATIVE EXCELLENCE POLITICAL ACTION COMMITTEE (RUST PAC",
        "CMTE_ID" : "C00500843",
        "AMNDT_IND" : "A",
        "RPT_TP" : "Q1",
        "TRANSACTION_PGI" : "P",
        "IMAGE_NUM" : "12020311894",
        "TRANSACTION_TP" : "22Z",
        "ENTITY_TP" : "",
        "NAME" : "RUST CONSULTING INC ADMINISTRATIVE",
        "CITY" : "MINNEAPOLIS",
        "STATE" : "MN",
        "ZIP_CODE" : "55402",
        "EMPLOYER" : "",
        "OCCUPATION" : "",
        "TRANSACTION_DT" : "03082012",
        "TRANSACTION_AMT" : 500,
        "OTHER_ID" : "C00468223",
        "TRAN_ID" : "SB050914371217659",
        "FILE_NUM" : "782162",
        "MEMO_CD" : "",
        "MEMO_TEXT" : "",
        "SUB_ID" : "1070320120010102620",
        "donar_cat" : "big_fish"
}
...
```

Print the total amount for each donar_cat as final output. For this, I will use a subquery, as illustrated [here](https://docs.mongodb.com/manual/reference/sql-aggregation-comparison/), using the last sql example under "Count the number of distinct `cust_id`, `ord_date` groupings. Excludes the time portion of the date."

```shell
MongoDB Enterprise Cluster0-shard-0:PRIMARY> db.contrib_data.aggregate(
	[
		{
			$addFields:
			{
			donar_cat:
				{
				$cond: { if: {$gte: ["$TRANSACTION_AMT", 500] }, then: "big_fish", else: "small_fish"}
				}
			}
		},
		{
			 $group: {
				_id: "$donar_cat",
				total: { $sum: "$TRANSACTION_AMT" }
			}
		}
	]
)
{ "_id" : "big_fish", "total" : 48747084 }
{ "_id" : "small_fish", "total" : 53278 }
```

List the top 5 cmte_received by TRANSACTION_AMT, using [this](https://docs.mongodb.com/manual/reference/sql-aggregation-comparison/) to sum, [this](https://docs.mongodb.com/manual/reference/method/db.collection.aggregate/) to sort and limit.

```powershell
MongoDB Enterprise Cluster0-shard-0:PRIMARY> db.contrib_data.aggregate( [
   {
     $group: {
        _id: "$cmte_received",
        total: { $sum: "$TRANSACTION_AMT" } } },
   { $sort: { total: -1 } },
   { $limit: 5 }
] )
{ "_id" : "MINNESOTA DEMOCRATIC - FARMER LABOR PARTY/FEDERALACCOUNTS", "total" : 8124432 }
{ "_id" : "INDEPENDENT-REPUBLICANS OF MINNESOTA", "total" : 6440080 }
{ "_id" : "BACHMANN FOR CONGRESS", "total" : 3522675 }
{ "_id" : "BACHMANN FOR PRESIDENT", "total" : 2852567 }
{ "_id" : "AL FRANKEN FOR SENATE 2014", "total" : 2786962 }

```

List the top 5 cmte_received by TRANSACTION_AMT that Michele Bachmann gave money to.

```powershell
MongoDB Enterprise Cluster0-shard-0:PRIMARY> db.contrib_data.aggregate( [
	{$match: { CAND_NAME: "BACHMANN, MICHELE" } },
	{
	$group: {
		_id: "$cmte_received",
        total: { $sum: "$TRANSACTION_AMT" } } },
	{ $sort: { total: -1 } },
	{ $limit: 5 }
] )
{ "_id" : "BACHMANN FOR CONGRESS", "total" : 3408348 }
{ "_id" : "BACHMANN FOR PRESIDENT", "total" : 2850067 }
{ "_id" : "INDEPENDENT-REPUBLICANS OF MINNESOTA", "total" : 371703 }
{ "_id" : "MINNESOTA - BACHMANN VICTORY COMMITTEE", "total" : 99600 }
{ "_id" : "ACPAC ACA INTERNATIONAL POLITICAL ACTION COMMITTEE", "total" : 20000 }
```

**Finally, terminate your Atlas cluster.**

