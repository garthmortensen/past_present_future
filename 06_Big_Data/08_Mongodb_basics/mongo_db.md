# Big Data

MongoDB Basics  

2020.04.24  

## Overview

MongoDB is an open-source document database that provides high performance, high availability, and automatic scaling.  

Mongo's default file format is BSON (binary json). Jsons get converted into Bson. It contains a pk called ObjectID.  

This documentation walks through the registration, connection and basic usage of MongoDB.

## Exploration

### Register 

Go to [cloud.mongodb.com](https://cloud.mongodb.com/). MongoDB Atlas Global Cloud Database lets you deploy and operate a fully elastic, HA db.  

[Register](https://www.mongodb.com/download-center?jmp=nav) for a free account. Use a "Shared Cluster" as a free option, and click "Create Cluster". Wait about 5-10 minutes until golden-brown.

### Setup Security

Atlas requires authentication before you can access the cluster. To do that, we create a database user.  

Under Security on the left, select “Database Access” > Add New Database User. Create an Atlas admin user: admin/admin. For User Privileges, select Atlas admin.  

Now whitelist your IP under Network Access > Add IP Address > Add Current IP Address (and select a timer).  

### Connect

On the left menu, click Clusters > Connect > Connect to Mongo Shell > Download.  

Extract the .zip to C:\MongoDB.  

Add it to PATH using [this](https://www.architectryan.com/2018/03/17/add-to-the-path-on-windows-10/) guide.  

Connect to the db using the connection string provided by Atlas.  

```cmd
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

### Run Basic Commands

help

```cmd
MongoDB Enterprise Cluster0-shard-0:PRIMARY> help
        db.help()                    help on db methods
        db.mycoll.help()             help on collection methods
        sh.help()                    sharding helpers
        rs.help()                    replica set helpers
        help admin                   administrative help
        help connect                 connecting to a db help
        help keys                    key shortcuts
        help misc                    misc things to know
        help mr                      mapreduce

        show dbs                     show database names
        show collections             show collections in current database
        show users                   show users in current database
        show profile                 show most recent system.profile entries with time >= 1ms
        show logs                    show the accessible logger names
        show log [name]              prints out the last segment of log in memory, 'global' is default
        use <db_name>                set current database
        db.foo.find()                list objects in collection foo
        db.foo.find( { a : 1 } )     list objects in foo where a == 1
        it                           result of the last line evaluated; use to further iterate
        DBQuery.shellBatchSize = x   set default number of items to display on shell
        exit                         quit the mongo shell
```

db.help 

```cmd
MongoDB Enterprise Cluster0-shard-0:PRIMARY> db.emp.help()
DBCollection help
        db.emp.find().help() - show DBCursor help
        db.emp.bulkWrite( operations, <optional params> ) - bulk execute write operations, optional parameters are: w, wtimeout, j
        db.emp.count( query = {}, <optional params> ) - count the number of documents that matches the query, optional parameters are: limit, skip, hint, maxTimeMS
        db.emp.countDocuments( query = {}, <optional params> ) - count the number of documents that matches the query, optional parameters are: limit, skip, hint, maxTimeMS
        db.emp.estimatedDocumentCount( <optional params> ) - estimate the document count using collection metadata, optional parameters are: maxTimeMS
        ...
```

show dbs

```cmd
MongoDB Enterprise Cluster0-shard-0:PRIMARY> show dbs
admin  0.000GB
local  3.788GB
```

use local

```cmd
MongoDB Enterprise Cluster0-shard-0:PRIMARY> use local
switched to db local
```

show collections

```cmd
MongoDB Enterprise Cluster0-shard-0:PRIMARY> show collections
clustermanager
oplog.rs
replset.election
replset.minvalid
replset.oplogTruncateAfterPoint
startup_log
```

db.emp.help()

```cmd
MongoDB Enterprise Cluster0-shard-0:PRIMARY> db.emp.help()
DBCollection help
        db.emp.find().help() - show DBCursor help
        db.emp.bulkWrite( operations, <optional params> ) - bulk execute write operations, optional parameters are: w, wtimeout, j
        db.emp.count( query = {}, <optional params> ) - count the number of documents that matches the query, optional parameters are: limit, skip, hint, maxTimeMS
        db.emp.countDocuments( query = {}, <optional params> ) - count the number of documents that matches the query, optional parameters are: limit, skip, hint, maxTimeMS
        db.emp.estimatedDocumentCount( <optional params> ) - estimate the document count using collection metadata, optional parameters are: maxTimeMS
        db.emp.convertToCapped(maxBytes) - calls {convertToCapped:'emp', size:maxBytes}} command
        db.emp.createIndex(keypattern[,options])
        db.emp.createIndexes([keypatterns], <options>)
...
```

#### Create database & create collection

use test

```cmd
MongoDB Enterprise Cluster0-shard-0:PRIMARY> use test
switched to db test
```

show dbs

```cmd
MongoDB Enterprise Cluster0-shard-0:PRIMARY> show dbs
admin  0.000GB
local  1.016GB
```

Insert into collection

```cmd
MongoDB Enterprise Cluster0-shard-0:PRIMARY> db.emps.insert({_id: 1, Name: "Garth"})
WriteResult({ "nInserted" : 1 })
```

show dbs

```cmd
MongoDB Enterprise Cluster0-shard-0:PRIMARY> show dbs
admin  0.000GB
local  1.016GB
test   0.000GB
```

show collections

```cmd
MongoDB Enterprise Cluster0-shard-0:PRIMARY> show collections
emps
```

query collection

```cmd
MongoDB Enterprise Cluster0-shard-0:PRIMARY> db.emps.find()
{ "_id" : 1, "Name" : "Garth" }
```

### Create Collection and do some CRUD operations

Create a collection and perform operations such as create, update and delete, and also do read queries. 

Create a new db.

```cmd
MongoDB Enterprise Cluster0-shard-0:PRIMARY> use mydb
switched to db mydb
```

Create countries collection, with three documents.

```cmd
MongoDB Enterprise Cluster0-shard-0:PRIMARY> db.countries.insert({_id : "us",
... name : "United States",
... exports : {
... foods : [
... { name : "bacon", tasty : true },
... { name : "burgers" }]
... }
... });
WriteResult({ "nInserted" : 1 })
MongoDB Enterprise Cluster0-shard-0:PRIMARY> db.countries.insert({_id : "ca",
... name : "Canada",
... exports : {
... foods : [
... { name : "bacon", tasty : false },
... { name : "syrup", tasty : true }]
... }
... });
WriteResult({ "nInserted" : 1 })
MongoDB Enterprise Cluster0-shard-0:PRIMARY> db.countries.insert({_id : "mx",
... name : "Mexico",
... exports : {
... foods : [
... {name : "salsa", tasty : true, condiment : true}]
... }
... });
WriteResult({ "nInserted" : 1 })
```

Query collection

 ```cmd
MongoDB Enterprise Cluster0-shard-0:PRIMARY> db.countries.find()
{ "_id" : "us", "name" : "United States", "exports" : { "foods" : [ { "name" : "bacon", "tasty" : true }, { "name" : "burgers" } ] } }
{ "_id" : "ca", "name" : "Canada", "exports" : { "foods" : [ { "name" : "bacon", "tasty" : false }, { "name" : "syrup", "tasty" : true } ] } }
{ "_id" : "mx", "name" : "Mexico", "exports" : { "foods" : [ { "name" : "salsa", "tasty" : true, "condiment" : true } ] } }
 ```

Make that pretty

```cmd
MongoDB Enterprise Cluster0-shard-0:PRIMARY> db.countries.find().pretty()
{
        "_id" : "us",
        "name" : "United States",
        "exports" : {
                "foods" : [
                        {
                                "name" : "bacon",
                                "tasty" : true
                        },
                        {
                                "name" : "burgers"
                        }
                ]
        }
}
{
        "_id" : "ca",
        "name" : "Canada",
        "exports" : {
                "foods" : [
                        {
                                "name" : "bacon",
                                "tasty" : false
                        },
                        {
                                "name" : "syrup",
                                "tasty" : true
                        }
                ]
        }
}
{
        "_id" : "mx",
        "name" : "Mexico",
        "exports" : {
                "foods" : [
                        {
                                "name" : "salsa",
                                "tasty" : true,
                                "condiment" : true
                        }
                ]
        }
}
```

Lookup a specific value

```cmd
MongoDB Enterprise Cluster0-shard-0:PRIMARY> db.countries.find({"name" : "United States"}).pretty()
{
        "_id" : "us",
        "name" : "United States",
        "exports" : {
                "foods" : [
                        {
                                "name" : "bacon",
                                "tasty" : true
                        },
                        {
                                "name" : "burgers"
                        }
                ]
        }
}
```

#### Example queries

print values

```cmd
MongoDB Enterprise Cluster0-shard-0:PRIMARY> db.countries.find(
... { _id : "ca"},
... { name : 1 }
... )
{ "_id" : "ca", "name" : "Canada" }
```

print only specific fields 

```cmd
MongoDB Enterprise Cluster0-shard-0:PRIMARY> db.countries.find(
... { name : /^U/},
... {_id : 0, name : 1 }
... )
{ "name" : "United States" }
```

another

```cmd
MongoDB Enterprise Cluster0-shard-0:PRIMARY> db.countries.find(
... { 'exports.foods.name' : /^s/ },
... { _id :0, name : 1 }
... )
{ "name" : "Canada" }
{ "name" : "Mexico" }
```

another

```cmd
MongoDB Enterprise Cluster0-shard-0:PRIMARY> db.countries.find(
... { 'exports.foods' : {
... $elemMatch : {
... name : 'bacon',
... tasty : true }
... }},
... { _id : 0, name : 1 })
{ "name" : "United States" }
```

#### Create variables and insert data

You can use variables in mongodb.

```cmd
MongoDB Enterprise Cluster0-shard-0:PRIMARY> var p = {_id: "1",
...    author: "Saeed",
...           date: new Date(),
...           text: "Distributed DBS",
...           tags: ["Wiley", "GPS", "UST"]}

# now type in that variable name
MongoDB Enterprise Cluster0-shard-0:PRIMARY> p
{
        "_id" : "1",
        "author" : "Saeed",
        "date" : ISODate("2020-04-25T01:00:16.086Z"),
        "text" : "Distributed DBS",
        "tags" : [
                "Wiley",
                "GPS",
                "UST"
        ]
}
```

Save that variable content to a collection.

```cmd
MongoDB Enterprise Cluster0-shard-0:PRIMARY> db.books.save(p)
WriteResult({ "nMatched" : 0, "nUpserted" : 1, "nModified" : 0, "_id" : "1" })
```

Now find the content of that collection.

```cmd
MongoDB Enterprise Cluster0-shard-0:PRIMARY> db.books.find().pretty()
{
        "_id" : "1",
        "author" : "Saeed",
        "date" : ISODate("2020-04-25T01:00:16.086Z"),
        "text" : "Distributed DBS",
        "tags" : [
                "Wiley",
                "GPS",
                "UST"
        ]
}
```

Define a new variable.

```cmd
MongoDB Enterprise Cluster0-shard-0:PRIMARY> var p2 = { _id: "2",
...           author: "Saeed",
...           date: new Date(),
...           text: "Distributed DBS",
...           tags: ["Wiley", "Engineering", "St. Thomas"],
...           price: 120}
```

Save variable content to collection.

```cmd
MongoDB Enterprise Cluster0-shard-0:PRIMARY> db.books.save(p2)
WriteResult({ "nMatched" : 0, "nUpserted" : 1, "nModified" : 0, "_id" : "2" })
```

Display results

```cmd
MongoDB Enterprise Cluster0-shard-0:PRIMARY> db.books.find({_id : "2"}).pretty()
{
        "_id" : "2",
        "author" : "Saeed",
        "date" : ISODate("2020-04-25T01:04:15.955Z"),
        "text" : "Distributed DBS",
        "tags" : [
                "Wiley",
                "Engineering",
                "St. Thomas"
        ],
        "price" : 120
}
```

Create a secondary index. Look at subsequent cmd as well before you start wondering about this.

```cmd
MongoDB Enterprise Cluster0-shard-0:PRIMARY> db.books.ensureIndex({author: 1})
{
        "createdCollectionAutomatically" : false,
        "numIndexesBefore" : 1,
        "numIndexesAfter" : 2,
        "ok" : 1,
        "$clusterTime" : {
                "clusterTime" : Timestamp(1587776788, 2),
                "signature" : {
                        "hash" : BinData(0,"wC4sUp4il56fJwrTIdfxuzC+kXg="),
                        "keyId" : NumberLong("6819179696811409409")
                }
        },
        "operationTime" : Timestamp(1587776788, 2)
}
```

Show results.

```cmd
# see that second id?
MongoDB Enterprise Cluster0-shard-0:PRIMARY> db.books.find({_id : "2"}).pretty()
{
        "_id" : "2",
        "author" : "Saeed",
        "date" : ISODate("2020-04-25T01:04:15.955Z"),
        "text" : "Distributed DBS",
        "tags" : [
                "Wiley",
                "Engineering",
                "St. Thomas"
        ],
        "price" : 120
}
```

Exit.

```cmd
MongoDB Enterprise Cluster0-shard-0:PRIMARY> exit
bye
```

It says Bye. That's nice.  

**Finally, terminate your Atlas cluster.**

