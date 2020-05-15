# Cassandra vs HBase

## How to Select Between Them?

The relational database model has dominated the market for decades, thanks to its strong ability to normalize data and define table relationships. However, in response to continuously increasing volume, velocity and variety of data, a new burst of innovative~~, ~~ NoSQL database solutions have been designed. The new arrivals can be categorized into many different models, with the main ones being Document (MongoDB), Wide column store/Column family (Cassandra), Key-value (Redis) and Graph (Neo4j).

The following examines the leading Wide column store solution, Cassandra, which db-engines.com scores on par with MS Access. Questions to be answered include what makes Cassandra special, who uses it, how it compares to HBase, and what this author thinks about it.

According to the [CAP (Brewer’s) Theorem](https://en.wikipedia.org/wiki/CAP_theorem), a distributed database can only simultaneously demonstrate two of the following three properties: Consistency, Availability and Partition Tolerance. In a Consistent system, every reader always gets the same view of the data (you never get two different answers from a query). Availability is the system’s ability to accept read/writes. A Partition Tolerant system is one that still works even if partitions/servers have their communications interrupted.

[Wide column store solutions](https://www.alexdebrie.com/posts/choosing-a-database-with-pie/) including BigTable, Hypertable and HBase are Consistent, allowing all clients to always have the same view of the data, and they are partition tolerant, so they work well despite occasional network issues. Meanwhile, the column store solution Vertica is consistent and available, so each client can always read/write (“CA”).

Cassandra is different because it is both available and Partitioned Tolerant (“AP”), so it achieves “eventual consistency” through replication and verifications. That is, it ensures that data is available for read/write, even if it means sometimes [losing consistency](https://www.datastax.com/blog/2019/05/how-apache-cassandratm-balances-consistency-availability-and-performance) (the same query could return different answers). 

According to [cassandra.apache.org](https://cassandra.apache.org), the database is used by over 1,500 organizations “that have large, active datasets” including CERN, Comcast, eBay, GitHub, GoDaddy, Hulu, Instagram, Intuit, Netflix, Reddit and The Weather Channel. You’ll notice that these organizations have very large datasets. Cassandra handles large datasets that may be sparse and have new columns added quite well.

We can see on [db-engines.com/en/ranking](https://db-engines.com/en/ranking) that Cassandra has gained ground over the years to become the 11th highest-scored (popular) database solution.

Comparing Cassandra to HBase can be a bit murky, as they are both quite similar and differences only show up in the somewhat technical details. After all, Cassandra and HBase are both Wide column stores, they both handle very sparse data, and are both Apache projects. They also share a vast majority of features and only deviate on a few. Namely, Cassandra supports 13 major programming languages, but HBase only 8. Cassandra does not support server-side scripts or have in-memory capabilities, while HBase does. 

Distinguishing between them requires a look at their underlying design philosophies. While neither support real-time transactions, HBase offers strong [record-level consistency](https://www.infoworld.com/article/2610656/big-data-showdown--cassandra-vs--hbase.html?page=2) and [ACID-level semantics](http://hbase.apache.org/acid-semantics.html). You can also lock rows. Therefore, when you need Consistent data across all nodes, go with HBase. While Cassandra is not Consistent, recall that it will eventually achieve consistency. It’s a trade-off for Cassandra’s ability to always remain available. If you [can’t afford any downtime](https://www.scnsoft.com/blog/cassandra-vs-hbase), choose Cassandra. Finally, Cassandra has an SQL-like syntax called CQL that your analysts can use to explore the data.

The database has potential, but also limitations. As is true for nearly all NoSQL solutions, Cassandra has a challenging learning curve for many relational database administrators and users. While it may be feasible to set up and integrate Cassandra into your company, it still requires user-training before it’s business as usual again. Moreover, since databases are typically the foundation upon which many critical analyses and intelligence are built from, there is additional risk of any mishap snowballing further down the data supply chain. Because the system is “eventually Consistent”, meaning the same query can return two different answers, I don’t think Cassandra is ideal for running analyses/intelligence on either.

That said, Cassandra is attractive because your data is fault-tolerant via replication, and because it is highly performant and scalable. It’s also an open source apache project, meaning there are no licensing costs. And even though it’s open source, the creators still offer professional support. That means expert answers are available when you need someone to lean on. Otherwise, because it’s so widely used, there is considerable online discussion and Q&A for you to learn from. Finally, that popularity gives it momentum to grow, lending credibility to its future. 

**Appendix**

![img](file:///C:/Users/morte/AppData/Local/Temp/msohtmlclip1/01/clip_image002.png)

Image 1, model market share (https://db-engines.com/en/ranking)

**Sources**

\1. “CAP Theorem.” *Wikipedia*, Wikimedia Foundation, 25 Dec. 2019, [en.wikipedia.org/wiki/CAP_theorem](https://en.wikipedia.org/wiki/CAP_theorem).

\2. “Why the PIE Theorem Is More Relevant than the CAP Theorem.” Alex DeBrie – Serverless AWS, [alexdebrie.com/posts/choosing-a-database-with-pie/](http://www.alexdebrie.com/posts/choosing-a-database-with-pie/). 

\3. “How Apache Cassandra Balances Consistency, Availability, and Performance.” Datastax, [datastax.com/blog/2019/05/how-apache-cassandratm-balances-consistency-availability-and-performance](https://www.datastax.com/blog/2019/05/how-apache-cassandratm-balances-consistency-availability-and-performance).

\4. “Manage Massive Amounts of Data, Fast, without Losing Sleep.” Apache Cassandra, cassandra.apache.org/. [cassandra.apache.org/](https://cassandra.apache.org/).

\5. “Engines Ranking.” DB, [db-engines.com/en/ranking](https://db-engines.com/en/ranking).

\6. “Big data showdown: Cassandra vs. HBase.” InfoWorld, Rick Grehan, 2 Apr. 2014, [hinfoworld.com/article/2610656/big-data-showdown--cassandra-vs--hbase.html?page=1](https://www.infoworld.com/article/2610656/big-data-showdown--cassandra-vs--hbase.html?page=1).

\7. “Apache HBase.” Apache, [hbase.apache.org/acid-semantics.html](http://hbase.apache.org/acid-semantics.html).

\8. “Cassandra vs. HBase: twins or just strangers with similar looks?” ScienceSoft, Alex Bekker, 29 Jun 2018, [scnsoft.com/blog/cassandra-vs-hbase](https://www.scnsoft.com/blog/cassandra-vs-hbase).