# MapReduce

Garth Mortensen  

2020.01.19  



This is an exploration of the [MapReduce](https://en.wikipedia.org/wiki/MapReduce) concept.  

Three folders were created, each containing some .txt documents. For this exploration, I treated each folder as if it was a node in a big data cluster. When you think of it this way, then each node contains multiple data files.  

Each node processes the data in its file system (the folder), producing a key-value pair map.  

The final function emulates the master node, by accepting all the other node's maps, and reducing it in a single operation.  

It's a simplification, just a fun exercise.